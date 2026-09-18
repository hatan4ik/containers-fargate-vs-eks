// @ts-check

import { randomUUID } from "node:crypto";
import { pinoHttp } from "pino-http";

const requestIdPattern = /^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$/;

/** @param {string | string[] | undefined} header */
function validRequestId(header) {
  const value = Array.isArray(header) ? header[0] : header;
  return value && requestIdPattern.test(value) ? value : undefined;
}

/** @param {import("pino").Logger} logger */
export function requestContext(logger) {
  return pinoHttp({
    logger,
    genReqId(request, response) {
      const requestId =
        validRequestId(request.headers["x-request-id"]) ?? randomUUID();
      response.setHeader("x-request-id", requestId);
      return requestId;
    },
    customProps(request) {
      return { requestId: request.id };
    },
  });
}
