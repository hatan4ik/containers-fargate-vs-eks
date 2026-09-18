// @ts-check

import express from "express";

/** @param {import("express").Express} app */
export function addCommonRoutes(app) {
  app.disable("x-powered-by");
  app.get("/healthz", (_request, response) =>
    response.status(200).json({ ok: true }),
  );
  app.get("/readyz", (_request, response) =>
    response.status(200).json({ ready: true }),
  );
}

/** @returns {import("express").RequestHandler} */
export function jsonBodyParser() {
  return express.json({ limit: "32kb", type: "application/json" });
}

/** @returns {import("express").ErrorRequestHandler} */
export function errorHandler() {
  return (error, request, response, next) => {
    if (response.headersSent) {
      return next(error);
    }

    if (error instanceof SyntaxError && "body" in error) {
      request.log.warn({ err: error.message }, "invalid JSON request body");
      return response.status(400).json({ error: "invalid JSON request body" });
    }

    request.log.error({ err: error }, "unhandled request error");
    return response.status(500).json({ error: "internal server error" });
  };
}

/** @param {unknown} value */
export function isRecord(value) {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
