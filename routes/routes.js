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

/**
 * Marketplace Admin
 *
 * Handles administrative marketplace operations.
 */
const marketplaceAdminRoutes = require("./marketplace-admin");

router.use("/marketplace-admin", marketplaceAdminRoutes);

/**
 * Wallet Admin
 *
 * Handles administrative wallet management.
 */
const walletAdminRoutes = require("./wallet-admin");

router.use("/wallet-admin", walletAdminRoutes);

/**
 * =========================================================
 * USER WALLET ROUTES
 * =========================================================
 */

/**
 * Wallet
 *
 * Handles user wallet information and wallet operations.
 */
const walletRoutes = require("./wallet");

router.use("/wallet", walletRoutes);

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
 * Current admin modules:
 *
 * - Marketplace Admin
 * - Wallet Admin
 *
 * Future admin modules will be registered here
 * after they are completed and tested.
 */

/**
 * =========================================================
 * REGISTERED USER MODULES
 * =========================================================
 *
 * Current user modules:
 *
 * - Wallet
 *
 * Future user modules will be registered progressively.
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
