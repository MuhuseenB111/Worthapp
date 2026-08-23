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

function sendSuccess(
  response,
  statusCode,
  data
) {
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

  return response
    .status(statusCode)
    .json(payload);
}

/**
 * =========================================================
 * REGISTER
 * =========================================================
 */

async function register(request, response) {
  try {
    const {
      email,
      password,
      displayName
    } = request.body || {};

    const user =
      await registerUser({
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

    return sendError(
      response,
      400,
      error.message ||
        "Unable to create account."
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
    const {
      email,
      password
    } = request.body || {};

    const ipAddress =
      request.ip || null;

    const userAgent =
      request.get("user-agent") || null;

    const result =
      await loginUser({
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
        user: result.user,
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
        error.message,
        "AUTH_ACCOUNT_NOT_ACTIVE"
      );
    }

    return sendError(
      response,
      400,
      error.message ||
        "Unable to login."
    );
  }
}

/**
 * =========================================================
 * LOGOUT
 * =========================================================
 *
 * Full server-side session revocation will be connected
 * when refresh-token/session handling is enabled.
 *
 * For the current JWT access-token architecture,
 * the client removes its access token.
 * =========================================================
 */

async function logout(request, response) {
  try {
    return sendSuccess(
      response,
      200,
      {
        message:
          "Logout successful. Remove the access token from the client."
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
      "Unable to logout."
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
      status: "available",
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
