// @ts-check

import { httpUrl, positiveInteger } from "../../shared/src/config.js";

/** @param {NodeJS.ProcessEnv} environment */
export function gatewayConfig(environment = process.env) {
  return {
    ordersBaseUrl: httpUrl(
      environment.ORDERS_BASE_URL,
      "http://orders:3002",
      "ORDERS_BASE_URL",
    ),
    ordersTimeoutMs: positiveInteger(
      environment.ORDERS_TIMEOUT_MS,
      2_500,
      "ORDERS_TIMEOUT_MS",
    ),
    port: positiveInteger(environment.PORT, 3_000, "PORT"),
  };
}
