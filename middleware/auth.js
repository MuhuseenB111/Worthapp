"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * AUTHENTICATION MIDDLEWARE
 *
 * File: middleware/auth.js
 *
 * Responsibilities:
 * - Read Bearer access token
 * - Verify JWT
 * - Load authenticated user
 * - Check account status
 * - Attach user to request
 * - Protect private routes
 * =========================================================
 */

const jwt = require("jsonwebtoken");

const {
  pool
} = require("../database/connection");

/**
 * =========================================================
 * CONFIGURATION
 * =========================================================
 */

const AUTHORIZATION_HEADER = "authorization";

const BEARER_PREFIX = "Bearer ";

const JWT_ISSUER = "worthapp";

const JWT_AUDIENCE = "worthapp-api";

/**
 * =========================================================
 * AUTHORIZATION HEADER
 * =========================================================
 */

function getAuthorizationHeader(request) {
  return (
    request.headers?.[AUTHORIZATION_HEADER] ||
    null
  );
}

/**
 * =========================================================
 * EXTRACT BEARER TOKEN
 * =========================================================
 */

function extractBearerToken(request) {
  const authorization =
    getAuthorizationHeader(request);

  if (!authorization) {
    return null;
  }

  if (
    !authorization.startsWith(BEARER_PREFIX)
  ) {
    return null;
  }

  const token =
    authorization
      .slice(BEARER_PREFIX.length)
      .trim();

  if (!token) {
    return null;
  }

  return token;
}

/**
 * =========================================================
 * GET JWT SECRET
 * =========================================================
 */

function getJwtSecret() {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new Error(
      "JWT_SECRET environment variable is not configured."
    );
  }

  return secret;
}

/**
 * =========================================================
 * VERIFY ACCESS TOKEN
 * =========================================================
 */

function verifyAccessToken(token) {
  return jwt.verify(
    token,
    getJwtSecret(),
    {
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE
    }
  );
}

/**
 * =========================================================
 * LOAD USER FROM DATABASE
 * =========================================================
 */

async function loadAuthenticatedUser(userId) {
  const result = await pool.query(
    `
    SELECT
      id,
      email,
      display_name,
      status,
      email_verified,
      created_at,
      updated_at,
      last_login_at
    FROM users
    WHERE id = $1
    LIMIT 1
    `,
    [userId]
  );

  if (result.rows.length === 0) {
    return null;
  }

  return result.rows[0];
}

/**
 * =========================================================
 * AUTHENTICATION MIDDLEWARE
 * =========================================================
 *
 * This middleware:
 *
 * 1. Reads Authorization header
 * 2. Extracts Bearer token
 * 3. Verifies JWT
 * 4. Finds user in database
 * 5. Checks account status
 * 6. Attaches authenticated user
 */

async function authenticate(request, response, next) {
  try {
    /**
     * -------------------------------------------------------
     * GET TOKEN
     * -------------------------------------------------------
     */

    const token =
      extractBearerToken(request);

    if (!token) {
      return response.status(401).json({
        success: false,
        error: "Authentication required.",
        code: "AUTH_TOKEN_REQUIRED"
      });
    }

    /**
     * -------------------------------------------------------
     * VERIFY TOKEN
     * -------------------------------------------------------
     */

    let decoded;

    try {
      decoded =
        verifyAccessToken(token);
    } catch (error) {
      if (
        error.name ===
        "TokenExpiredError"
      ) {
        return response.status(401).json({
          success: false,
          error: "Access token has expired.",
          code: "AUTH_TOKEN_EXPIRED"
        });
      }

      return response.status(401).json({
        success: false,
        error: "Invalid access token.",
        code: "AUTH_INVALID_TOKEN"
      });
    }

    /**
     * -------------------------------------------------------
     * VERIFY USER ID
     * -------------------------------------------------------
     */

    if (!decoded.sub) {
      return response.status(401).json({
        success: false,
        error: "Invalid authentication identity.",
        code: "AUTH_INVALID_SUBJECT"
      });
    }

    /**
     * -------------------------------------------------------
     * LOAD USER
     * -------------------------------------------------------
     */

    const user =
      await loadAuthenticatedUser(
        decoded.sub
      );

    if (!user) {
      return response.status(401).json({
        success: false,
        error: "Authenticated user was not found.",
        code: "AUTH_USER_NOT_FOUND"
      });
    }

    /**
     * -------------------------------------------------------
     * CHECK ACCOUNT STATUS
     * -------------------------------------------------------
     */

    if (user.status !== "active") {
      return response.status(403).json({
        success: false,
        error: "This account is not active.",
        code: "AUTH_ACCOUNT_NOT_ACTIVE"
      });
    }

    /**
     * -------------------------------------------------------
     * ATTACH AUTHENTICATED USER
     * -------------------------------------------------------
     */

    attachAuthenticatedUser(
      request,
      user
    );

    /**
     * -------------------------------------------------------
     * ATTACH JWT PAYLOAD
     * -------------------------------------------------------
     */

    request.authenticatedToken =
      Object.freeze({
        ...decoded
      });

    /**
     * -------------------------------------------------------
     * CONTINUE
     * -------------------------------------------------------
     */

    return next();
  } catch (error) {
    console.error(
      "Worthapp authentication middleware error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Authentication service temporarily unavailable.",
      code: "AUTH_MIDDLEWARE_ERROR"
    });
  }
}

/**
 * =========================================================
 * REQUIRE AUTHENTICATION
 * =========================================================
 *
 * Use this middleware on protected routes.
 *
 * Example:
 *
 * router.get(
 *   "/profile",
 *   authenticate,
 *   requireAuthentication,
 *   controller
 * );
 */

function requireAuthentication(
  request,
  response,
  next
) {
  if (!request.authenticatedUser) {
    return response.status(401).json({
      success: false,
      error: "Authentication required.",
      code: "AUTH_REQUIRED"
    });
  }

  return next();
}

/**
 * =========================================================
 * ATTACH AUTHENTICATED USER
 * =========================================================
 */

function attachAuthenticatedUser(
  request,
  user
) {
  if (
    !user ||
    typeof user !== "object"
  ) {
    throw new TypeError(
      "An authenticated user object is required."
    );
  }

  request.authenticatedUser =
    Object.freeze({
      ...user
    });
}

/**
 * =========================================================
 * CHECK AUTHENTICATION
 * =========================================================
 */

function isAuthenticated(request) {
  return Boolean(
    request.authenticatedUser
  );
}

/**
 * =========================================================
 * GET CURRENT AUTHENTICATED USER
 * ========================================================= */

function getAuthenticatedUser(request) {
  return (
    request.authenticatedUser ||
    null
  );
}

/**
 * =========================================================
 * MODULE EXPORTS
 * =========================================================
 */

module.exports = {
  getAuthorizationHeader,
  extractBearerToken,
  verifyAccessToken,
  authenticate,
  requireAuthentication,
  attachAuthenticatedUser,
  isAuthenticated,
  getAuthenticatedUser
};
