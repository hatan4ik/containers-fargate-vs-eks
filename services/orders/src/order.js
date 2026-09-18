// @ts-check

import { randomUUID } from "node:crypto";

/** @param {unknown} value */
function nonEmptyText(value) {
  return (
    typeof value === "string" && value.trim().length > 0 && value.length <= 256
  );
}

/** @param {unknown} body */
export function validateOrder(body) {
  if (typeof body !== "object" || body === null || Array.isArray(body)) {
    return ["request body must be a JSON object"];
  }

  const candidate = /** @type {{ userId?: unknown, item?: unknown }} */ (body);
  const errors = [];
  if (!nonEmptyText(candidate.userId)) {
    errors.push("userId must be a non-empty string up to 256 characters");
  }
  if (!nonEmptyText(candidate.item)) {
    errors.push("item must be a non-empty string up to 256 characters");
  }
  return errors;
}

/**
 * @param {{ user: unknown, item: string, idGenerator?: () => string }} input
 */
export function newOrder({ user, item, idGenerator = randomUUID }) {
  return { id: `ord_${idGenerator()}`, user, item, status: "created" };
}
