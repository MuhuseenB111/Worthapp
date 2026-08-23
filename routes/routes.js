"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * CENTRAL ROUTE REGISTRY
 *
 * File: routes/routes.js
 *
 * Responsible for registering and organizing
 * Worthapp API route modules.
 * =========================================================
 */

const express = require("express");

const router = express.Router();

/**
 * =========================================================
 * AUTHENTICATION ROUTES
 * =========================================================
 */

const authRoutes = require("./auth");

router.use("/auth", authRoutes);

/**
 * =========================================================
 * HEALTH ROUTES
 * =========================================================
 */

const healthRoutes = require("./health");

router.use("/health", healthRoutes);

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
 * CATEGORIES ROUTES
 * =========================================================
 */

const categoriesRoutes = require("./categories");

router.use("/categories", categoriesRoutes);

/**
 * =========================================================
 * MARKETPLACE ADMIN ROUTES
 * =========================================================
 */

const marketplaceAdminRoutes = require("./marketplace-admin");

router.use(
  "/marketplace-admin",
  marketplaceAdminRoutes
);

/**
 * =========================================================
 * API INFORMATION
 * =========================================================
 *
 * GET /api/v1/
 * =========================================================
 */

router.get("/", (req, res) => {
  res.status(200).json({
    success: true,

    platform: "Worthapp",

    message:
      "Worthapp API is running successfully.",

    version: "1.0.0",

    apiVersion: "v1",

    environment:
      process.env.NODE_ENV || "development",

    apiBase: "/api/v1",

    timestamp:
      new Date().toISOString()
  });
});

/**
 * =========================================================
 * API VERSION
 * =========================================================
 *
 * GET /api/v1/version
 * =========================================================
 */

router.get("/version", (req, res) => {
  res.status(200).json({
    success: true,

    platform: "Worthapp",

    apiVersion: "v1",

    applicationVersion: "1.0.0",

    environment:
      process.env.NODE_ENV || "development",

    timestamp:
      new Date().toISOString()
  });
});

/**
 * =========================================================
 * REGISTERED ROUTE MODULES
 * =========================================================
 *
 * Current modules:
 *
 * /auth
 * /health
 * /wallet
 * /products
 * /categories
 * /marketplace-admin
 *
 * More modules will be connected progressively
 * after their individual implementation and testing.
 * =========================================================
 */

/**
 * =========================================================
 * FUTURE ROUTE MODULES
 * =========================================================
 *
 * Za mu haɗa su a hankali bayan an gina
 * kuma an gwada kowanne module:
 *
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
 * Ba za mu haɗa su ba sai an kammala
 * implementation da testing.
 * =========================================================
 */

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 */

module.exports = router;
