"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * USER ROUTES
 *
 * File: routes/users.js
 *
 * Responsibilities:
 * - User service status
 * - Authenticated current-user endpoint
 * - User profile foundation
 * - Prepare user routes for controllers/services
 * =========================================================
 */

const express = require("express");

const router = express.Router();

/**
 * =========================================================
 * AUTHENTICATION MIDDLEWARE
 * =========================================================
 */

const {
  authenticate,
  requireAuthentication,
  getAuthenticatedUser
} = require("../middleware/auth");

/**
 * =========================================================
 * USER SERVICE STATUS
 * =========================================================
 *
 * GET /api/v1/users/status
 *
 * This endpoint remains public.
 */

router.get(
  "/status",
  (request, response) => {
    return response.status(200).json({
      success: true,
      service: "Worthapp User Service",
      status: "available",
      message:
        "Worthapp user service is ready.",
      timestamp:
        new Date().toISOString()
    });
  }
);

/**
 * =========================================================
 * GET CURRENT AUTHENTICATED USER
 * =========================================================
 *
 * GET /api/v1/users/me
 *
 * This endpoint requires a valid JWT.
 *
 * Authorization:
 *
 * Bearer <access-token>
 */

router.get(
  "/me",
  authenticate,
  requireAuthentication,
  (request, response) => {
    const user =
      getAuthenticatedUser(request);

    if (!user) {
      return response.status(401).json({
        success: false,
        error:
          "Authenticated user was not found.",
        code:
          "AUTH_USER_NOT_FOUND"
      });
    }

    return response.status(200).json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        displayName:
          user.display_name ||
          null,
        status: user.status,
        emailVerified:
          user.email_verified,
        createdAt:
          user.created_at,
        updatedAt:
          user.updated_at,
        lastLoginAt:
          user.last_login_at
      }
    });
  }
);

/**
 * =========================================================
 * GET USER PROFILE
 * =========================================================
 *
 * GET /api/v1/users/:userId
 *
 * Database profile controller/service will be
 * connected in the next development stage.
 */

router.get(
  "/:userId",
  authenticate,
  requireAuthentication,
  (request, response) => {
    return response.status(501).json({
      success: false,
      message:
        "User profile service is not connected yet.",
      code:
        "USER_PROFILE_NOT_READY"
    });
  }
);

/**
 * =========================================================
 * UPDATE USER PROFILE
 * =========================================================
 *
 * PATCH /api/v1/users/:userId
 *
 * Validation and controller/service logic will be
 * connected after the user service foundation
 * is completed.
 */

router.patch(
  "/:userId",
  authenticate,
  requireAuthentication,
  (request, response) => {
    return response.status(501).json({
      success: false,
      message:
        "User profile update service is not connected yet.",
      code:
        "USER_UPDATE_NOT_READY"
    });
  }
);

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 */

module.exports = router;
