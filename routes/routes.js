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
 * Responsibilities:
 * - Register all Worthapp API route modules
 * - Provide API information
 * - Provide API health status
 * - Provide API version information
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

router.use(
  "/auth",
  authRoutes
);

/**
 * =========================================================
 * USER ROUTES
 * =========================================================
 */

const userRoutes = require("./users");

router.use(
  "/users",
  userRoutes
);

/**
 * =========================================================
 * WALLET ROUTES
 * =========================================================
 */

const walletRoutes = require("./wallet");

router.use(
  "/wallet",
  walletRoutes
);

/**
 * =========================================================
 * PRODUCTS ROUTES
 * =========================================================
 */

const productsRoutes =
  require("./products");

router.use(
  "/products",
  productsRoutes
);

/**
 * =========================================================
 * CATEGORIES ROUTES
 * =========================================================
 */

const categoriesRoutes =
  require("./categories");

router.use(
  "/categories",
  categoriesRoutes
);

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
 * GET /api/v1/
 */

router.get(
  "/",
  (request, response) => {
    return response.status(200).json({
      success: true,
      platform: "Worthapp",

      message:
        "Worthapp API is running successfully.",

      version: "1.0.0",

      environment:
        process.env.NODE_ENV ||
        "development",

      apiBase:
        "/api/v1",

      timestamp:
        new Date().toISOString()
    });
  }
);

/**
 * =========================================================
 * API HEALTH
 * =========================================================
 *
 * GET /api/v1/health
 */

router.get(
  "/health",
  (request, response) => {
    return response.status(200).json({
      success: true,

      service:
        "Worthapp API",

      status:
        "healthy",

      timestamp:
        new Date().toISOString()
    });
  }
);

/**
 * =========================================================
 * API VERSION
 * =========================================================
 *
 * GET /api/v1/version
 */

router.get(
  "/version",
  (request, response) => {
    return response.status(200).json({
      success: true,

      platform:
        "Worthapp",

      apiVersion:
        "v1",

      applicationVersion:
        "1.0.0"
    });
  }
);

/**
 * =========================================================
 * REGISTERED ROUTE MODULES
 * =========================================================
 *
 * Authentication:
 * /auth
 *
 * Users:
 * /users
 *
 * Marketplace:
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
