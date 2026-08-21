"use strict";

/**
 * Worthapp
 * Global Digital Platform
 *
 * Central route registry.
 * File 20
 *
 * This file keeps application routes organized
 * and ready for future modules such as:
 * - Authentication
 * - Users
 * - Messaging
 * - AI
 * - Marketplace
 * - Payments
 * - Knowledge
 * - Entertainment
 * - Notifications
 * - Administration
 */

const express = require("express");

const router = express.Router();

/**
 * ---------------------------------------------------------
 * API INFORMATION
 * ---------------------------------------------------------
 */

router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    platform: "Worthapp",
    message: "Worthapp API is running successfully.",
    version: "1.0.0",
    environment: process.env.NODE_ENV || "development",
    timestamp: new Date().toISOString()
  });
});

/**
 * ---------------------------------------------------------
 * API HEALTH
 * ---------------------------------------------------------
 */

router.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    service: "Worthapp API",
    status: "healthy",
    timestamp: new Date().toISOString()
  });
});

/**
 * ---------------------------------------------------------
 * API VERSION
 * ---------------------------------------------------------
 */

router.get("/version", (req, res) => {
  res.status(200).json({
    success: true,
    platform: "Worthapp",
    apiVersion: "v1",
    applicationVersion: "1.0.0"
  });
});

/**
 * ---------------------------------------------------------
 * FUTURE ROUTE MODULES
 * ---------------------------------------------------------
 *
 * Za mu haɗa waɗannan routes a hankali yayin da project
 * yake girma:
 *
 * /auth
 * /users
 * /profiles
 * /messages
 * /ai
 * /marketplace
 * /payments
 * /knowledge
 * /entertainment
 * /notifications
 * /admin
 *
 * Ba mu haɗa su yanzu domin kada mu kira files
 * waɗanda ba mu gina ba tukuna.
 */

module.exports = router;
