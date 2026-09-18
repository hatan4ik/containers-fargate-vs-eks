// @ts-check

/**
 * @param {string | undefined} value
 * @param {number} fallback
 * @param {string} name
 */
export function positiveInteger(value, fallback, name) {
  const parsed = value === undefined ? fallback : Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer`);
  }
  return parsed;
}

/**
 * @param {string | undefined} value
 * @param {number} fallback
 * @param {string} name
 */
export function nonNegativeInteger(value, fallback, name) {
  const parsed = value === undefined ? fallback : Number(value);
  if (!Number.isInteger(parsed) || parsed < 0) {
    throw new Error(`${name} must be a non-negative integer`);
  }
  return parsed;
}

/**
 * @param {string | undefined} value
 * @param {string} fallback
 * @param {string} name
 */
export function httpUrl(value, fallback, name) {
  let parsed;
  try {
    parsed = new URL(value ?? fallback);
  } catch {
    throw new Error(`${name} must be an absolute HTTP(S) URL`);
  }

  if (
    (parsed.protocol !== "http:" && parsed.protocol !== "https:") ||
    parsed.username ||
    parsed.password ||
    parsed.search ||
    parsed.hash
  ) {
    throw new Error(
      `${name} must be an absolute HTTP(S) URL without credentials`,
    );
  }

  return parsed.toString().replace(/\/$/, "");
}
