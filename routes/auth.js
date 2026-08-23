"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * AUTHENTICATION ROUTES
 *
 * File: routes/auth.js
 *
 * Responsibilities:
 * - Register users
 * - Login users
 * - Logout users
 * - Authentication service status
 * =========================================================
 */

const express = require("express");

const router = express.Router();

/**
 * =========================================================
 * AUTHENTICATION CONTROLLER
 * =========================================================
 */

const {
  register,
  login,
  logout,
  status
} = require("../controllers/authController");

/**
 * =========================================================
 * AUTHENTICATION SERVICE STATUS
 * =========================================================
 *
 * GET /api/v1/auth/status
 */

router.get(
  "/status",
  status
);

/**
 * =========================================================
 * REGISTER
 * =========================================================
 *
 * POST /api/v1/auth/register
 *
 * Expected body:
 *
 * {
 *   "email": "user@example.com",
 *   "password": "StrongPassword123!",
 *   "displayName": "User Name"
 * }
 */

router.post(
  "/register",
  register
);

/**
 * =========================================================
 * LOGIN
 * =========================================================
 *
 * POST /api/v1/auth/login
 *
 * Expected body:
 *
 * {
 *   "email": "user@example.com",
 *   "password": "StrongPassword123!"
 * }
 */

router.post(
  "/login",
  login
);

/**
 * =========================================================
 * LOGOUT
 * =========================================================
 *
 * POST /api/v1/auth/logout
 */

router.post(
  "/logout",
  logout
);

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 */

module.exports = router;
