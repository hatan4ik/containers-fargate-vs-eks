// @ts-check

import express from "express";
import {
  addCommonRoutes,
  errorHandler,
  jsonBodyParser,
} from "../../shared/src/app.js";
import { requestContext } from "../../shared/src/request-context.js";

/** @param {{ logger: import("pino").Logger, artificialLatencyMs: number }} dependencies */
export function createUsersApp({ logger, artificialLatencyMs }) {
  const app = express();
  app.use(requestContext(logger));
  app.use(jsonBodyParser());
  addCommonRoutes(app);

  app.get("/users/:id", async (request, response) => {
    if (artificialLatencyMs > 0) {
      await new Promise((resolve) => setTimeout(resolve, artificialLatencyMs));
    }
    const { id } = request.params;
    return response.json({ id, name: `user-${id}`, tier: "standard" });
  });

  app.use(errorHandler());
  return app;
}
