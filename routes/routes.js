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
 * - Connect user authentication and user services
 * =========================================================
 */

const express = require("express");

const router = express.Router();

/**
 * =========================================================
 * AUTHENTICATION ROUTES
 * =========================================================
 *
 * Base:
 * /api/v1/auth
 *
 * Examples:
 * POST /api/v1/auth/register
 * POST /api/v1/auth/login
 * POST /api/v1/auth/logout
 * GET  /api/v1/auth/status
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
 *
 * Base:
 * /api/v1/users
 *
 * Examples:
 * GET   /api/v1/users/status
 * GET   /api/v1/users/me
 * GET   /api/v1/users/:userId
 * PATCH /api/v1/users/:userId
 */

const usersRoutes = require("./users");

router.use(
  "/users",
  usersRoutes
);

/**
 * =========================================================
 * WALLET ROUTES
 * =========================================================
 *
 * Base:
 * /api/v1/wallet
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
 *
 * Base:
 * /api/v1/products
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
 *
 * Base:
 * /api/v1/categories
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
 *
 * Base:
 * /api/v1/marketplace-admin
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

      platform:
        "Worthapp",

      message:
        "Worthapp API is running successfully.",

      version:
        "1.0.0",

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
 *
 * This checks the API routing layer.
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
 * These modules are being connected progressively.
 */

/**
 * =========================================================
 * FUTURE ROUTE MODULES
 * =========================================================
 *
 * Za mu haɗa su a hankali bayan mun
 * kammala gwaji:
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
 * /settings
 * /search
 * /orders
 * /reviews
 * /shipping
 * /transactions
 * /vendors
 *
 * Ba za mu haɗa su ba sai mun
 * duba code ɗinsu kuma mun tabbatar
 * da dependencies ɗinsu.
 */

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 */

module.exports = router;
