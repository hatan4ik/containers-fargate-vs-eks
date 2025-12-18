import express from "express";
import pino from "pino";
import pinoHttp from "pino-http";

const log = pino({ level: process.env.LOG_LEVEL || "info" });
const app = express();
app.use(express.json());
app.use(pinoHttp({ logger: log }));

const port = Number(process.env.PORT || 3001);
const artificialLatencyMs = Number(process.env.ARTIFICIAL_LATENCY_MS || 0);

app.get("/healthz", (_req, res) => res.status(200).json({ ok: true }));

app.get("/users/:id", async (req, res) => {
  const { id } = req.params;
  if (artificialLatencyMs > 0) await new Promise(r => setTimeout(r, artificialLatencyMs));
  res.json({ id, name: `user-${id}`, tier: "standard" });
});

app.listen(port, () => log.info({ port, artificialLatencyMs }, "users listening"));
