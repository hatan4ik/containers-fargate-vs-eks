// @ts-check

import assert from "node:assert/strict";
import test from "node:test";
import pino from "pino";
import { UpstreamTimeoutError } from "../../shared/src/errors.js";
import { serve } from "../../shared/test/server.js";
import { createOrdersApp } from "../src/app.js";
import { ordersConfig } from "../src/config.js";

const logger = pino({ level: "silent" });

test("orders validates its input and creates a collision-resistant ID", async () => {
  /** @type {unknown} */
  let received;
  const app = createOrdersApp({
    logger,
    idGenerator: () => "fixed-uuid",
    usersClient: {
      async getUser(request) {
        received = request;
        return {
          status: 200,
          body: { id: "123", name: "user-123", tier: "standard" },
        };
      },
    },
  });
  const server = await serve(app);

  try {
    const invalid = await fetch(`${server.baseUrl}/orders`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ userId: 123, item: "" }),
    });
    assert.equal(invalid.status, 400);

    const response = await fetch(`${server.baseUrl}/orders`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-request-id": "trace-456",
      },
      body: JSON.stringify({ userId: "123", item: "demo" }),
    });
    assert.equal(response.status, 201);
    assert.deepEqual(await response.json(), {
      id: "ord_fixed-uuid",
      item: "demo",
      status: "created",
      user: { id: "123", name: "user-123", tier: "standard" },
    });
    assert.deepEqual(received, { requestId: "trace-456", userId: "123" });
  } finally {
    await server.close();
  }
});

test("orders maps timeout and non-success dependency outcomes safely", async () => {
  const timeoutApp = createOrdersApp({
    logger,
    usersClient: {
      async getUser() {
        throw new UpstreamTimeoutError();
      },
    },
  });
  const timeoutServer = await serve(timeoutApp);

  try {
    const response = await fetch(`${timeoutServer.baseUrl}/orders`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ userId: "123", item: "demo" }),
    });
    assert.equal(response.status, 504);
  } finally {
    await timeoutServer.close();
  }

  const unavailableApp = createOrdersApp({
    logger,
    usersClient: {
      async getUser() {
        return { status: 500, body: { secret: "hidden" } };
      },
    },
  });
  const unavailableServer = await serve(unavailableApp);

  try {
    const response = await fetch(`${unavailableServer.baseUrl}/orders`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ userId: "123", item: "demo" }),
    });
    assert.equal(response.status, 502);
    assert.deepEqual(await response.json(), {
      error: "users dependency failed",
    });
  } finally {
    await unavailableServer.close();
  }
});

test("orders configuration rejects invalid deployment settings", () => {
  assert.throws(
    () => ordersConfig({ USERS_TIMEOUT_MS: "0" }),
    /USERS_TIMEOUT_MS/,
  );
});
