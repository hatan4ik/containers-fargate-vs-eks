// @ts-check

export class UpstreamTimeoutError extends Error {
  constructor() {
    super("The upstream service did not respond before the timeout");
    this.name = "UpstreamTimeoutError";
  }
}

export class UpstreamUnavailableError extends Error {
  /** @param {unknown} cause */
  constructor(cause) {
    super("The upstream service could not be reached", { cause });
    this.name = "UpstreamUnavailableError";
  }
}

export class UpstreamProtocolError extends Error {
  /** @param {number} status */
  constructor(status) {
    super("The upstream service returned an invalid JSON response");
    this.name = "UpstreamProtocolError";
    this.status = status;
  }
}
