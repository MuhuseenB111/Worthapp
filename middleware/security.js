"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * SECURITY MIDDLEWARE
 *
 * File: middleware/security.js
 *
 * Responsibilities:
 * - Apply HTTP security headers
 * - Reduce browser-based attack surface
 * - Control cross-origin browser behavior
 * - Prevent sensitive response caching
 * =========================================================
 */

/**
 * =========================================================
 * SECURITY HEADERS
 * =========================================================
 */

const SECURITY_HEADERS = Object.freeze({
  "X-Content-Type-Options": "nosniff",

  "X-Frame-Options": "DENY",

  "Referrer-Policy": "no-referrer",

  "Permissions-Policy":
    "camera=(), microphone=(), geolocation=()",

  "Cache-Control": "no-store",

  "Cross-Origin-Opener-Policy":
    "same-origin",

  "Cross-Origin-Resource-Policy":
    "same-origin"
});

/**
 * =========================================================
 * APPLY SECURITY HEADERS
 * =========================================================
 */

function applySecurityHeaders(response) {
  if (!response || typeof response.setHeader !== "function") {
    throw new TypeError(
      "A valid HTTP response object is required."
    );
  }

  for (
    const [name, value]
    of Object.entries(SECURITY_HEADERS)
  ) {
    response.setHeader(name, value);
  }
}

/**
 * =========================================================
 * SECURITY MIDDLEWARE
 * =========================================================
 *
 * Express usage:
 *
 * app.use(securityMiddleware);
 *
 */

function securityMiddleware(
  request,
  response,
  next
) {
  try {
    applySecurityHeaders(response);

    return next();
  } catch (error) {
    console.error(
      "Worthapp security middleware error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Security middleware error."
    });
  }
}

/**
 * =========================================================
 * GET SECURITY HEADERS
 * =========================================================
 *
 * Returns a copy so the original configuration
 * cannot be modified accidentally.
 *
 */

function getSecurityHeaders() {
  return {
    ...SECURITY_HEADERS
  };
}

/**
 * =========================================================
 * MODULE EXPORTS
 * =========================================================
 *
 * Worthapp uses CommonJS.
 *
 */

module.exports = {
  SECURITY_HEADERS,
  applySecurityHeaders,
  securityMiddleware,
  getSecurityHeaders
};
