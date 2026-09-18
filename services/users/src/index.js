import pino from "pino";
import { startServer } from "../../shared/src/server.js";
import { createUsersApp } from "./app.js";
import { usersConfig } from "./config.js";

const config = usersConfig();
const logger = pino({ level: process.env.LOG_LEVEL ?? "info" });
const app = createUsersApp({
  logger,
  artificialLatencyMs: config.artificialLatencyMs,
});

startServer({ app, port: config.port, logger, serviceName: "users" });
