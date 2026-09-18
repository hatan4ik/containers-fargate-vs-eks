// @ts-check

import assert from "node:assert/strict";
import test from "node:test";
import pino from "pino";
import { UpstreamTimeoutError } from "../../shared/src/errors.js";
import { serve } from "../../shared/test/server.js";
import { createGatewayApp } from "../src/app.js";
import { gatewayConfig } from "../src/config.js";

const logger = pino({ level: "silent" });

test("gateway forwards the contract and request ID", async () => {
  /** @type {unknown} */
  let received;
  const app = createGatewayApp({
    logger,
    ordersClient: {
      async checkout(request) {
        received = request;
        return { status: 201, body: { id: "ord_123", status: "created" } };
      },
    },
  });
  const server = await serve(app);

  try {
    const response = await fetch(`${server.baseUrl}/checkout`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-request-id": "trace-123",
      },
      body: JSON.stringify({ userId: "123", item: "demo" }),
    });

    assert.equal(response.status, 201);
    assert.equal(response.headers.get("x-request-id"), "trace-123");
    assert.deepEqual(received, {
      payload: { userId: "123", item: "demo" },
      requestId: "trace-123",
    });
  } finally {
    await server.close();
  }
});

test("gateway rejects malformed payloads and maps an upstream timeout", async () => {
  const app = createGatewayApp({
    logger,
    ordersClient: {
      async checkout() {
        throw new UpstreamTimeoutError();
      },
    },
  });
  const server = await serve(app);

  try {
    const malformed = await fetch(`${server.baseUrl}/checkout`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: "{",
    });
    assert.equal(malformed.status, 400);

    const timeout = await fetch(`${server.baseUrl}/checkout`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ userId: "123", item: "demo" }),
    });
    assert.equal(timeout.status, 504);
    assert.deepEqual(await timeout.json(), { error: "orders timeout" });
  } finally {
    await server.close();
  }
});

test("gateway configuration rejects invalid deployment settings", () => {
  assert.throws(
    () => gatewayConfig({ PORT: "not-a-port" }),
    /PORT must be a positive integer/,
  );
  assert.throws(
    () => gatewayConfig({ ORDERS_BASE_URL: "ftp://orders" }),
    /ORDERS_BASE_URL must be an absolute HTTP/,
  );
});
