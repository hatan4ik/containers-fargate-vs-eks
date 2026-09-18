// @ts-check

import express from "express";
import {
  addCommonRoutes,
  errorHandler,
  isRecord,
  jsonBodyParser,
} from "../../shared/src/app.js";
import {
  UpstreamProtocolError,
  UpstreamTimeoutError,
  UpstreamUnavailableError,
} from "../../shared/src/errors.js";
import { requestContext } from "../../shared/src/request-context.js";

/**
 * @typedef {{ checkout: (request: { payload: Record<string, unknown>, requestId: string }) => Promise<{ status: number, body: unknown }> }} OrdersClient
 */

/** @param {{ logger: import("pino").Logger, ordersClient: OrdersClient }} dependencies */
export function createGatewayApp({ logger, ordersClient }) {
  const app = express();
  app.use(requestContext(logger));
  app.use(jsonBodyParser());
  addCommonRoutes(app);

  app.post("/checkout", async (request, response, next) => {
    if (!isRecord(request.body)) {
      return response
        .status(400)
        .json({ error: "request body must be a JSON object" });
    }

    try {
      const result = await ordersClient.checkout({
        payload: request.body,
        requestId: String(request.id),
      });
      return response.status(result.status).json(result.body);
    } catch (error) {
      if (error instanceof UpstreamTimeoutError) {
        return response.status(504).json({ error: "orders timeout" });
      }
      if (
        error instanceof UpstreamUnavailableError ||
        error instanceof UpstreamProtocolError
      ) {
        return response.status(502).json({ error: "orders dependency failed" });
      }
      return next(error);
    }
  });

  app.use(errorHandler());
  return app;
}
