"use strict";

/**
 * Worthapp
 * Global Digital Platform
 *
 * Central Route Registry
 *
 * File 65
 *
 * This file is responsible for registering
 * Worthapp API routes and future route modules.
 */

const express = require("express");

const router = express.Router();

/**
 * =========================================================
 * ADMIN ROUTES
 * =========================================================
 */

// Marketplace Admin
const marketplaceAdminRoutes = require("./marketplace-admin");

router.use("/marketplace-admin", marketplaceAdminRoutes);

/**
 * =========================================================
 * API INFORMATION
 * =========================================================
 */

router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    platform: "Worthapp",
    message: "Worthapp API is running successfully",
    version: "1.0.0",
    environment: process.env.NODE_ENV || "development",
    timestamp: new Date().toISOString()
  });
});

/**
 * =========================================================
 * API HEALTH
 * =========================================================
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
 * =========================================================
 * API VERSION
 * =========================================================
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
 * =========================================================
 * REGISTERED ADMIN MODULES
 * =========================================================
 *
 * These modules are being built progressively.
 *
 * Current admin module:
 * - Marketplace Admin
 *
 * Future modules will be registered here
 * after they are completed and tested.
 */

/**
 * =========================================================
 * FUTURE ROUTE MODULES
 * =========================================================
 *
 * Za mu haɗa waɗannan routes a hankali yayin da
 * Worthapp yake girma:
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
 * Ba mu haɗa su yanzu ba saboda muna gina su
 * ɗaya bayan ɗaya domin kauce wa matsala.
 */

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 */

module.exports = router;
