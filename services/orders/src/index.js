import express from "express";
import pino from "pino";
import pinoHttp from "pino-http";
import fetch from "node-fetch";

const log = pino({ level: process.env.LOG_LEVEL || "info" });
const app = express();
app.use(express.json());
app.use(pinoHttp({ logger: log }));

const port = Number(process.env.PORT || 3002);
const usersBaseUrl = process.env.USERS_BASE_URL || "http://users:3001";
const usersTimeoutMs = Number(process.env.USERS_TIMEOUT_MS || 2000);

app.get("/healthz", (_req, res) => res.status(200).json({ ok: true }));

app.post("/orders", async (req, res) => {
  const { userId, item } = req.body || {};
  if (!userId || !item) return res.status(400).json({ error: "userId and item are required" });

  let u;
  try {
    u = await fetch(`${usersBaseUrl}/users/${encodeURIComponent(userId)}`, { timeout: usersTimeoutMs });
  } catch (e) {
    req.log.warn({ err: String(e) }, "users request failed");
    return res.status(504).json({ error: "users timeout" });
  }

  if (!u.ok) return res.status(502).json({ error: "users dependency failed" });

  const user = await u.json();
  res.status(201).json({
    id: `ord_${Date.now()}`,
    user,
    item,
    status: "created",
  });
});

app.listen(port, () => log.info({ port, usersBaseUrl, usersTimeoutMs }, "orders listening"));
