// @ts-check

import { requestJson } from "../../shared/src/http.js";

/**
 * @param {{ baseUrl: string, timeoutMs: number, fetchImpl?: typeof fetch }} options
 */
export function createUsersClient({ baseUrl, timeoutMs, fetchImpl }) {
  return {
    /** @param {{ userId: string, requestId: string }} request */
    getUser: ({ userId, requestId }) =>
      requestJson({
        url: `${baseUrl}/users/${encodeURIComponent(userId)}`,
        method: "GET",
        headers: { "x-request-id": requestId },
        timeoutMs,
        fetchImpl,
      }),
  };
}
