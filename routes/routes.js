"use strict";

/**
 * Worthapp
 * Global Digital Platform
 *
 * Central Route Registry
 *
 * File: routes/routes.js
 *
 * Responsible for registering
 * Worthapp API route modules.
 */

const express = require("express");

const router = express.Router();

/**
 * =========================================================
 * WALLET ROUTES
 * =========================================================
 */

const walletRoutes = require("./wallet");

router.use("/wallet", walletRoutes);

/**
 * =========================================================
 * PRODUCTS ROUTES
 * =========================================================
 */

const productsRoutes = require("./products");

router.use("/products", productsRoutes);

/**
 * =========================================================
 * ADMIN ROUTES
 * =========================================================
 */

/**
 * Marketplace Admin
 */
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
    apiBase: "/api/v1",
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
 * REGISTERED ROUTE MODULES
 * =========================================================
 *
 * Current modules:
 *
 * /wallet
 * /products
 * /marketplace-admin
 *
 * Additional modules will be connected
 * progressively after testing.
 */

/**
 * =========================================================
 * FUTURE ROUTE MODULES
 * =========================================================
 *
 * Za mu haɗa su a hankali:
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
 * Ba za mu haɗa su ba sai mun
 * kammala kuma mun gwada su.
 */

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 */

module.exports = router;
