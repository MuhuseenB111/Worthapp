"use strict";

/**
 * Worthapp
 * Global Digital Platform
 *
 * Health Check Route
 * File 21
 *
 * Used to verify that the Worthapp API
 * is available and responding correctly.
 */

const express = require("express");

const router = express.Router();

/**
 * ---------------------------------------------------------
 * HEALTH CHECK
 * ---------------------------------------------------------
 */

router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    status: "healthy",
    service: "Worthapp API",
    message: "Worthapp API is running normally.",
    timestamp: new Date().toISOString()
  });
});

/**
 * ---------------------------------------------------------
 * DETAILED HEALTH CHECK
 * ---------------------------------------------------------
 */

router.get("/detailed", (req, res) => {
  res.status(200).json({
    success: true,
    status: "healthy",
    service: "Worthapp API",
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || "development",
    nodeVersion: process.version,
    timestamp: new Date().toISOString()
  });
});

/**
 * ---------------------------------------------------------
 * EXPORT ROUTER
 * ---------------------------------------------------------
 */

module.exports = router;
