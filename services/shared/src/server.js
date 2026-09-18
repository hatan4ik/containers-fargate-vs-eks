// @ts-check

/**
 * Start a server with a bounded, signal-aware shutdown path. Containers receive
 * SIGTERM before being replaced, so accepting no new connections is essential.
 *
 * @param {{ app: import("express").Express, port: number, logger: import("pino").Logger, serviceName: string }} options
 */
export function startServer({ app, port, logger, serviceName }) {
  const server = app.listen(port, () =>
    logger.info({ port }, `${serviceName} listening`),
  );
  let shuttingDown = false;

  /** @param {NodeJS.Signals} signal */
  const shutdown = (signal) => {
    if (shuttingDown) {
      return;
    }
    shuttingDown = true;
    logger.info({ signal }, "shutdown started");
    server.close((error) => {
      if (error) {
        logger.error({ err: error }, "shutdown failed");
        process.exitCode = 1;
      }
    });
    setTimeout(() => {
      logger.warn("forcing shutdown after grace period");
      server.closeAllConnections?.();
    }, 25_000).unref();
  };

  process.once("SIGTERM", () => shutdown("SIGTERM"));
  process.once("SIGINT", () => shutdown("SIGINT"));
  return server;
}
