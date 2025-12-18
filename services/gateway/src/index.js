import express from "express";
import pino from "pino";
import pinoHttp from "pino-http";
import fetch from "node-fetch";
import crypto from "crypto";

const log = pino({ level: process.env.LOG_LEVEL || "info" });
const app = express();
app.use(express.json());

// request-id propagation
app.use((req, res, next) => {
  const incoming = req.header("x-request-id");
  const rid = incoming || crypto.randomUUID();
  req.headers["x-request-id"] = rid;
  res.setHeader("x-request-id", rid);
  next();
});
app.use(pinoHttp({ logger: log }));

const port = Number(process.env.PORT || 3000);
const ordersBaseUrl = process.env.ORDERS_BASE_URL || "http://orders:3002";
const ordersTimeoutMs = Number(process.env.ORDERS_TIMEOUT_MS || 2500);

app.get("/healthz", (_req, res) => res.status(200).json({ ok: true }));

app.post("/checkout", async (req, res) => {
  const rid = req.headers["x-request-id"];
  let r;
  try {
    r = await fetch(`${ordersBaseUrl}/orders`, {
      method: "POST",
      headers: { "content-type": "application/json", "x-request-id": String(rid) },
      body: JSON.stringify(req.body || {}),
      timeout: ordersTimeoutMs,
    });
  } catch (e) {
    req.log.warn({ err: String(e) }, "orders request failed");
    return res.status(504).json({ error: "orders timeout" });
  }

  const body = await r.json().catch(() => ({}));
  return res.status(r.status).json(body);
});

app.listen(port, () => log.info({ port, ordersBaseUrl, ordersTimeoutMs }, "gateway listening"));
