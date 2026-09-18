// @ts-check

import assert from "node:assert/strict";
import test from "node:test";
import pino from "pino";
import { serve } from "../../shared/test/server.js";
import { createUsersApp } from "../src/app.js";
import { usersConfig } from "../src/config.js";

const logger = pino({ level: "silent" });

test("users exposes health, readiness, and the user contract", async () => {
  const server = await serve(
    createUsersApp({ logger, artificialLatencyMs: 0 }),
  );

  try {
    const health = await fetch(`${server.baseUrl}/healthz`);
    assert.equal(health.status, 200);
    assert.deepEqual(await health.json(), { ok: true });

    const readiness = await fetch(`${server.baseUrl}/readyz`);
    assert.equal(readiness.status, 200);

    const user = await fetch(`${server.baseUrl}/users/a%2Fb`, {
      headers: { "x-request-id": "trace-789" },
    });
    assert.equal(user.headers.get("x-request-id"), "trace-789");
    assert.deepEqual(await user.json(), {
      id: "a/b",
      name: "user-a/b",
      tier: "standard",
    });
  } finally {
    await server.close();
  }
});

test("users configuration permits zero latency but rejects negative latency", () => {
  assert.equal(
    usersConfig({ ARTIFICIAL_LATENCY_MS: "0" }).artificialLatencyMs,
    0,
  );
  assert.throws(
    () => usersConfig({ ARTIFICIAL_LATENCY_MS: "-1" }),
    /ARTIFICIAL_LATENCY_MS/,
  );
});
