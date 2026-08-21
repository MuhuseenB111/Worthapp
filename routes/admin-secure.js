"use strict";

/**
 * Worthapp
 * Global Digital Platform
 *
 * SECURE ADMIN DASHBOARD ROUTE
 * Build 68
 *
 * Purpose:
 * Connect the Admin Dashboard with the
 * administrator authentication middleware.
 *
 * Security flow:
 *
 * Request
 *    ↓
 * adminAuth
 *    ↓
 * Admin role verification
 *    ↓
 * Admin Dashboard
 *
 * This file does not modify:
 * - routes.js
 * - admin-dashboard.js
 * - auth.js
 * - roles.js
 */

const express = require("express");

const { adminAuth } = require("../middleware/admin-auth");

const adminDashboardRouter = require("./admin-dashboard");

const router = express.Router();

/* =========================================================
   SECURITY INFORMATION
   ========================================================= */

router.get("/", adminAuth, (req, res) => {
  res.status(200).json({
    success: true,
    platform: "Worthapp",
    module: "Secure Admin Dashboard",
    status: "authenticated",
    message: "Administrator authentication successful.",
    admin: {
      userId: req.admin.userId,
      role: req.admin.role
    },
    apiVersion: "v1",
    build: 68,
    timestamp: new Date().toISOString()
  });
});

/* =========================================================
   SECURE DASHBOARD ROUTES
   ========================================================= */

/*
 * All routes below this point require
 * administrator authentication.
 */

router.use(
  "/dashboard",
  adminAuth,
  adminDashboardRouter
);

/* =========================================================
   ADMIN SECURITY STATUS
   ========================================================= */

router.get("/security-status", adminAuth, (req, res) => {
  res.status(200).json({
    success: true,

    security: {
      authentication: "verified",
      authorization: "verified",
      administratorAccess: "granted",
      role: req.admin.role
    },

    admin: {
      userId: req.admin.userId
    },

    platform: "Worthapp",
    build: 68,
    timestamp: new Date().toISOString()
  });
});

/* =========================================================
   SECURE ADMIN HEALTH CHECK
   ========================================================= */

router.get("/health", adminAuth, (req, res) => {
  res.status(200).json({
    success: true,
    service: "Worthapp Secure Admin API",
    status: "healthy",
    authenticated: true,
    role: req.admin.role,
    build: 68,
    timestamp: new Date().toISOString()
  });
});

/* =========================================================
   API VERSION
   ========================================================= */

router.get("/version", adminAuth, (req, res) => {
  res.status(200).json({
    success: true,
    platform: "Worthapp",
    module: "Secure Admin API",
    apiVersion: "v1",
    build: 68,
    version: "1.0.0",
    authentication: "required"
  });
});

/* =========================================================
   SECURITY NOTICE
   ========================================================= */

router.get("/security-notice", adminAuth, (req, res) => {
  res.status(200).json({
    success: true,

    notice: {
      authentication: "Administrator authentication is required.",
      authorization: "Only approved administrator roles are allowed.",
      tokenType: "Bearer JWT",
      access: "Protected"
    },

    platform: "Worthapp",
    build: 68,
    timestamp: new Date().toISOString()
  });
});

/* =========================================================
   EXPORT ROUTER
   ========================================================= */

module.exports = router;
