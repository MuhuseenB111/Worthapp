"use strict";

/**
 * Worthapp
 * Global Digital Platform
 *
 * Authentication Routes
 * File 22
 *
 * This route module defines the authentication
 * endpoints that will later connect to the
 * authentication controllers and services.
 */

const express = require("express");

const router = express.Router();

/**
 * ---------------------------------------------------------
 * AUTHENTICATION SERVICE STATUS
 * ---------------------------------------------------------
 *
 * This endpoint confirms that the authentication
 * route is available.
 */

router.get("/status", (req, res) => {
  res.status(200).json({
    success: true,
    service: "Worthapp Authentication",
    status: "available",
    message: "Worthapp authentication service is ready.",
    timestamp: new Date().toISOString()
  });
});

/**
 * ---------------------------------------------------------
 * REGISTER
 * ---------------------------------------------------------
 *
 * Actual registration logic will be connected later
 * through the authentication controller/service.
 */

router.post("/register", (req, res) => {
  res.status(501).json({
    success: false,
    message: "Registration service is not connected yet.",
    code: "AUTH_REGISTER_NOT_READY"
  });
});

/**
 * ---------------------------------------------------------
 * LOGIN
 * ---------------------------------------------------------
 *
 * Actual login logic will be connected later
 * through the authentication controller/service.
 */

router.post("/login", (req, res) => {
  res.status(501).json({
    success: false,
    message: "Login service is not connected yet.",
    code: "AUTH_LOGIN_NOT_READY"
  });
});

/**
 * ---------------------------------------------------------
 * LOGOUT
 * ---------------------------------------------------------
 */

router.post("/logout", (req, res) => {
  res.status(501).json({
    success: false,
    message: "Logout service is not connected yet.",
    code: "AUTH_LOGOUT_NOT_READY"
  });
});

/**
 * ---------------------------------------------------------
 * EXPORT ROUTER
 * ---------------------------------------------------------
 */

module.exports = router;
