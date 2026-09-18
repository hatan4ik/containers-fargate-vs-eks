// @ts-check

import {
  nonNegativeInteger,
  positiveInteger,
} from "../../shared/src/config.js";

/** @param {NodeJS.ProcessEnv} environment */
export function usersConfig(environment = process.env) {
  return {
    artificialLatencyMs: nonNegativeInteger(
      environment.ARTIFICIAL_LATENCY_MS,
      0,
      "ARTIFICIAL_LATENCY_MS",
    ),
    port: positiveInteger(environment.PORT, 3_001, "PORT"),
  };
}
