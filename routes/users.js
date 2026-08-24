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
  updateUserProfile
} = require("../controllers/userController");

/**
 * =========================================================
 * USER SERVICE STATUS
 * =========================================================
 *
 * GET /api/v1/users/status
 *
 * This endpoint is public.
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
 * GET CURRENT USER
 * =========================================================
 *
 * GET /api/v1/users/me
 *
 * Authentication required.
 */

router.get(
  "/me",
  authenticate,
  getCurrentUser
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
 * Profile access will remain protected because
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
