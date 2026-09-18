import pino from "pino";
import { startServer } from "../../shared/src/server.js";
import { createGatewayApp } from "./app.js";
import { gatewayConfig } from "./config.js";
import { createOrdersClient } from "./orders-client.js";

const config = gatewayConfig();
const logger = pino({ level: process.env.LOG_LEVEL ?? "info" });
const ordersClient = createOrdersClient({
  baseUrl: config.ordersBaseUrl,
  timeoutMs: config.ordersTimeoutMs,
});
const app = createGatewayApp({ logger, ordersClient });

startServer({ app, port: config.port, logger, serviceName: "gateway" });
