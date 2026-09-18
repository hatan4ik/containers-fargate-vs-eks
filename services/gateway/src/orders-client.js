// @ts-check

import { requestJson } from "../../shared/src/http.js";

/**
 * @param {{ baseUrl: string, timeoutMs: number, fetchImpl?: typeof fetch }} options
 */
export function createOrdersClient({ baseUrl, timeoutMs, fetchImpl }) {
  return {
    /** @param {{ payload: Record<string, unknown>, requestId: string }} request */
    checkout: ({ payload, requestId }) =>
      requestJson({
        url: `${baseUrl}/orders`,
        method: "POST",
        headers: {
          "content-type": "application/json",
          "x-request-id": requestId,
        },
        body: payload,
        timeoutMs,
        fetchImpl,
      }),
  };
}
