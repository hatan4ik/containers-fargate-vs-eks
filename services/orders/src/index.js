import pino from "pino";
import { startServer } from "../../shared/src/server.js";
import { createOrdersApp } from "./app.js";
import { ordersConfig } from "./config.js";
import { createUsersClient } from "./users-client.js";

const config = ordersConfig();
const logger = pino({ level: process.env.LOG_LEVEL ?? "info" });
const usersClient = createUsersClient({
  baseUrl: config.usersBaseUrl,
  timeoutMs: config.usersTimeoutMs,
});
const app = createOrdersApp({ logger, usersClient });

startServer({ app, port: config.port, logger, serviceName: "orders" });
