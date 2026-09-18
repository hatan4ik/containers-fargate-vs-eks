// @ts-check

import { httpUrl, positiveInteger } from "../../shared/src/config.js";

/** @param {NodeJS.ProcessEnv} environment */
export function ordersConfig(environment = process.env) {
  return {
    port: positiveInteger(environment.PORT, 3_002, "PORT"),
    usersBaseUrl: httpUrl(
      environment.USERS_BASE_URL,
      "http://users:3001",
      "USERS_BASE_URL",
    ),
    usersTimeoutMs: positiveInteger(
      environment.USERS_TIMEOUT_MS,
      2_000,
      "USERS_TIMEOUT_MS",
    ),
  };
}
