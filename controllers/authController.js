"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * AUTHENTICATION CONTROLLER
 *
 * File: controllers/authController.js
 *
 * Responsibilities:
 * - Handle registration requests
 * - Handle login requests
 * - Handle logout requests
 * - Handle authentication status
 * - Connect HTTP requests to authService
 * =========================================================
 */

const {
  registerUser,
  loginUser,
  sanitizeUser
} = require("../services/authService");

/**
 * =========================================================
 * RESPONSE HELPERS
 * =========================================================
 */

function sendSuccess(response, statusCode, data = {}) {
  return response.status(statusCode).json({
    success: true,
    ...data
  });
}

function sendError(
  response,
  statusCode,
  message,
  code = null
) {
  const payload = {
    success: false,
    message
  };

  if (code) {
    payload.code = code;
  }

  return response.status(statusCode).json(payload);
}

/**
 * =========================================================
 * REQUEST VALIDATION
 * =========================================================
 */

function hasValidRequestBody(request) {
  return (
    request.body &&
    typeof request.body === "object" &&
    !Array.isArray(request.body)
  );
}

/**
 * =========================================================
 * REGISTER
 * =========================================================
 */

async function register(request, response) {
  try {
    if (!hasValidRequestBody(request)) {
      return sendError(
        response,
        400,
        "Request body must be a valid JSON object.",
        "AUTH_INVALID_REQUEST_BODY"
      );
    }

    const {
      email,
      password,
      displayName
    } = request.body;

    const user = await registerUser({
      email,
      password,
      displayName
    });

    return sendSuccess(
      response,
      201,
      {
        message:
          "Account created successfully.",
        user: sanitizeUser(user)
      }
    );
  } catch (error) {
    console.error(
      "Worthapp registration error:",
      error
    );

    if (
      error.code ===
      "AUTH_EMAIL_ALREADY_EXISTS"
    ) {
      return sendError(
        response,
        409,
        "An account with this email already exists.",
        error.code
      );
    }

    if (
      error.code ===
      "23505"
    ) {
      return sendError(
        response,
        409,
        "An account with this email already exists.",
        "AUTH_EMAIL_ALREADY_EXISTS"
      );
    }

    if (
      error.message &&
      (
        error.message.includes(
          "valid email address"
        ) ||
        error.message.includes(
          "Password must be"
        ) ||
        error.message.includes(
          "Display name must be"
        )
      )
    ) {
      return sendError(
        response,
        400,
        error.message,
        "AUTH_VALIDATION_ERROR"
      );
    }

    return sendError(
      response,
      500,
      "Unable to create account.",
      "AUTH_REGISTER_ERROR"
    );
  }
}

/**
 * =========================================================
 * LOGIN
 * =========================================================
 */

async function login(request, response) {
  try {
    if (!hasValidRequestBody(request)) {
      return sendError(
        response,
        400,
        "Request body must be a valid JSON object.",
        "AUTH_INVALID_REQUEST_BODY"
      );
    }

    const {
      email,
      password
    } = request.body;

    const ipAddress =
      request.ip || null;

    const userAgent =
      typeof request.get === "function"
        ? request.get("user-agent") || null
        : null;

    const result = await loginUser({
      email,
      password,
      ipAddress,
      userAgent
    });

    return sendSuccess(
      response,
      200,
      {
        message:
          "Login successful.",

        user:
          sanitizeUser(result.user),

        accessToken:
          result.accessToken,

        tokenType:
          result.tokenType,

        expiresIn:
          result.expiresIn
      }
    );
  } catch (error) {
    console.error(
      "Worthapp login error:",
      error
    );

    if (
      error.message ===
      "Invalid email or password."
    ) {
      return sendError(
        response,
        401,
        "Invalid email or password.",
        "AUTH_INVALID_CREDENTIALS"
      );
    }

    if (
      error.message ===
      "This account is not active."
    ) {
      return sendError(
        response,
        403,
        "This account is not active.",
        "AUTH_ACCOUNT_NOT_ACTIVE"
      );
    }

    if (
      error.message ===
      "JWT_SECRET must be configured and contain at least 32 characters."
    ) {
      return sendError(
        response,
        500,
        "Authentication security configuration is incomplete.",
        "AUTH_SECURITY_CONFIGURATION_ERROR"
      );
    }

    return sendError(
      response,
      500,
      "Unable to login.",
      "AUTH_LOGIN_ERROR"
    );
  }
}

/**
 * =========================================================
 * LOGOUT
 * =========================================================
 *
 * Current architecture uses JWT access tokens.
 *
 * The access token is currently stateless, therefore
 * the client must remove its token after logout.
 *
 * Server-side session/refresh-token revocation will be
 * connected when the session system is activated.
 * =========================================================
 */

async function logout(request, response) {
  try {
    return sendSuccess(
      response,
      200,
      {
        message:
          "Logout successful.",
        instruction:
          "Remove the access token from the client."
      }
    );
  } catch (error) {
    console.error(
      "Worthapp logout error:",
      error
    );

    return sendError(
      response,
      500,
      "Unable to logout.",
      "AUTH_LOGOUT_ERROR"
    );
  }
}

/**
 * =========================================================
 * AUTHENTICATION SERVICE STATUS
 * =========================================================
 */

async function status(request, response) {
  return sendSuccess(
    response,
    200,
    {
      service:
        "Worthapp Authentication",

      status:
        "available",

      message:
        "Worthapp authentication service is ready.",

      timestamp:
        new Date().toISOString()
    }
  );
}

/**
 * =========================================================
 * MODULE EXPORTS
 * =========================================================
 */

module.exports = {
  register,
  login,
  logout,
  status
};
