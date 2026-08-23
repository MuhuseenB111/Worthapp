"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * CENTRAL API ROUTE REGISTRY
 *
 * File: routes/routes.js
 *
 * Responsible for registering and organizing
 * all Worthapp API route modules.
 *
 * Main API prefix:
 * /api/v1
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

const marketplaceAdminRoutes =
  require("./marketplace-admin");

router.use(
  "/marketplace-admin",
  marketplaceAdminRoutes
);

/**
 * =========================================================
 * API INFORMATION
 * =========================================================
 *
 * GET /api/v1
 */

router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    platform: "Worthapp",
    message:
      "Worthapp API is running successfully.",
    version: "1.0.0",
    environment:
      process.env.NODE_ENV || "development",
    apiBase: "/api/v1",
    timestamp:
      new Date().toISOString()
  });
});

/**
 * =========================================================
 * API HEALTH
 * =========================================================
 *
 * GET /api/v1/health
 */

router.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    service: "Worthapp API",
    status: "healthy",
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
 * Current active modules:
 *
 * /auth
 * /wallet
 * /products
 * /categories
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
 * /search
 * /orders
 * /reviews
 * /settings
 *
 * Ba za mu kunna su sai mun
 * kammala kuma mun gwada su.
 */

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 */

module.exports = router;
