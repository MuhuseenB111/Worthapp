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
 * - Get current authenticated user
 * - Get user profile
 * - Update user profile
 * - Get user settings
 * - Update user settings
 * - Get complete user account
 * - Protect private user resources
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
  authenticate
} = require("../middleware/auth");

/**
 * =========================================================
 * USER CONTROLLER
 * =========================================================
 */

const {
  getCurrentUser,
  getUserProfile,
  updateUserProfile,
  getSettings,
  updateSettings,
  getCompleteAccount
} = require("../controllers/userController");

/**
 * =========================================================
 * USER SERVICE STATUS
 * =========================================================
 *
 * GET /api/v1/users/status
 *
 * Public endpoint.
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
 * Authentication required.
 *
 * IMPORTANT:
 * This route must remain BEFORE /:userId.
 */

router.get(
  "/me",
  authenticate,
  getCurrentUser
);

/**
 * =========================================================
 * GET USER SETTINGS
 * =========================================================
 *
 * GET /api/v1/users/:userId/settings
 *
 * Authentication required.
 *
 * A user can only access their own settings.
 */

router.get(
  "/:userId/settings",
  authenticate,
  getSettings
);

/**
 * =========================================================
 * UPDATE USER SETTINGS
 * =========================================================
 *
 * PATCH /api/v1/users/:userId/settings
 *
 * Authentication required.
 *
 * A user can only update their own settings.
 */

router.patch(
  "/:userId/settings",
  authenticate,
  updateSettings
);

/**
 * =========================================================
 * GET COMPLETE USER ACCOUNT
 * =========================================================
 *
 * GET /api/v1/users/:userId/account
 *
 * Returns:
 * - User information
 * - User profile
 * - User settings
 *
 * Authentication required.
 */

router.get(
  "/:userId/account",
  authenticate,
  getCompleteAccount
);

/**
 * =========================================================
 * GET USER PROFILE
 * =========================================================
 *
 * GET /api/v1/users/:userId
 *
 * Authentication required.
 *
 * Profile access remains protected because
 * Worthapp is designed as a privacy-first platform.
 */

router.get(
  "/:userId",
  authenticate,
  getUserProfile
);

/**
 * =========================================================
 * UPDATE USER PROFILE
 * =========================================================
 *
 * PATCH /api/v1/users/:userId
 *
 * Authentication required.
 *
 * The controller verifies that the authenticated
 * user owns the profile being updated.
 */

router.patch(
  "/:userId",
  authenticate,
  updateUserProfile
);

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 */

module.exports = router;
