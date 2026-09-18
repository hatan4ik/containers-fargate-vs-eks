// @ts-check

import {
  UpstreamProtocolError,
  UpstreamTimeoutError,
  UpstreamUnavailableError,
} from "./errors.js";

/**
 * @typedef {{ status: number, body: unknown }} JsonResponse
 */

/**
 * Make one bounded, JSON-only HTTP request. Deliberately does not retry: callers
 * must not replay a non-idempotent order creation after an uncertain timeout.
 *
 * @param {{ url: string, method: string, headers?: Record<string, string>, body?: unknown, timeoutMs: number, fetchImpl?: typeof fetch }} options
 * @returns {Promise<JsonResponse>}
 */
export async function requestJson({
  url,
  method,
  headers = {},
  body,
  timeoutMs,
  fetchImpl = fetch,
}) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  let response;
  try {
    response = await fetchImpl(url, {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body),
      signal: controller.signal,
    });
  } catch (error) {
    if (controller.signal.aborted) {
      throw new UpstreamTimeoutError();
    }
    throw new UpstreamUnavailableError(error);
  } finally {
    clearTimeout(timer);
  }

  const contentType = response.headers.get("content-type") ?? "";
  if (!contentType.toLowerCase().includes("application/json")) {
    throw new UpstreamProtocolError(response.status);
  }

  try {
    return { status: response.status, body: await response.json() };
  } catch {
    throw new UpstreamProtocolError(response.status);
  }
}
