// @ts-check

import express from "express";
import {
  addCommonRoutes,
  errorHandler,
  jsonBodyParser,
} from "../../shared/src/app.js";
import {
  UpstreamProtocolError,
  UpstreamTimeoutError,
  UpstreamUnavailableError,
} from "../../shared/src/errors.js";
import { requestContext } from "../../shared/src/request-context.js";
import { newOrder, validateOrder } from "./order.js";

/**
 * @typedef {{ getUser: (request: { userId: string, requestId: string }) => Promise<{ status: number, body: unknown }> }} UsersClient
 */

/** @param {{ logger: import("pino").Logger, usersClient: UsersClient, idGenerator?: () => string }} dependencies */
export function createOrdersApp({ logger, usersClient, idGenerator }) {
  const app = express();
  app.use(requestContext(logger));
  app.use(jsonBodyParser());
  addCommonRoutes(app);

  app.post("/orders", async (request, response, next) => {
    const errors = validateOrder(request.body);
    if (errors.length > 0) {
      return response
        .status(400)
        .json({ error: "invalid order", details: errors });
    }

    const order = /** @type {{ userId: string, item: string }} */ (
      request.body
    );
    try {
      const result = await usersClient.getUser({
        userId: order.userId,
        requestId: String(request.id),
      });
      if (result.status < 200 || result.status >= 300) {
        request.log.warn(
          { status: result.status },
          "users returned an error response",
        );
        return response.status(502).json({ error: "users dependency failed" });
      }
      return response
        .status(201)
        .json(newOrder({ user: result.body, item: order.item, idGenerator }));
    } catch (error) {
      if (error instanceof UpstreamTimeoutError) {
        return response.status(504).json({ error: "users timeout" });
      }
      if (
        error instanceof UpstreamUnavailableError ||
        error instanceof UpstreamProtocolError
      ) {
        return response.status(502).json({ error: "users dependency failed" });
      }
      return next(error);
    }
  });

  app.use(errorHandler());
  return app;
}
