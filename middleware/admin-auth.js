"use strict";

/**
 * Worthapp
 * Global Digital Platform
 *
 * ADMIN AUTHENTICATION MIDDLEWARE
 * Build 67
 *
 * Purpose:
 * Protect administrative API resources.
 *
 * This middleware:
 * - Verifies JWT access tokens
 * - Requires an authenticated user
 * - Checks administrator privileges
 * - Supports common admin roles
 *
 * This file is standalone and does not modify
 * existing authentication files.
 */

const jwt = require("jsonwebtoken");

/* =========================================================
   CONFIGURATION
   ========================================================= */

const JWT_SECRET = process.env.JWT_SECRET;

/* =========================================================
   ADMIN ROLES
   ========================================================= */

const ADMIN_ROLES = [
  "admin",
  "administrator",
  "superadmin",
  "super_admin",
  "platform_admin"
];

/* =========================================================
   TOKEN EXTRACTION
   ========================================================= */

function getTokenFromRequest(req) {
  const authorization = req.headers.authorization;

  if (!authorization) {
    return null;
  }

  const parts = authorization.trim().split(/\s+/);

  if (parts.length !== 2) {
    return null;
  }

  const scheme = parts[0].toLowerCase();
  const token = parts[1];

  if (scheme !== "bearer" || !token) {
    return null;
  }

  return token;
}

/* =========================================================
   ADMIN AUTHENTICATION
   ========================================================= */

function adminAuth(req, res, next) {
  try {
    if (!JWT_SECRET) {
      return res.status(500).json({
        success: false,
        error: "SERVER_CONFIGURATION_ERROR",
        message: "JWT_SECRET is not configured."
      });
    }

    const token = getTokenFromRequest(req);

    if (!token) {
      return res.status(401).json({
        success: false,
        error: "AUTHENTICATION_REQUIRED",
        message: "A valid Bearer access token is required."
      });
    }

    const decoded = jwt.verify(token, JWT_SECRET);

    if (!decoded || typeof decoded !== "object") {
      return res.status(401).json({
        success: false,
        error: "INVALID_TOKEN",
        message: "The access token is invalid."
      });
    }

    /*
     * Preserve the authenticated user for downstream
     * admin routes.
     */
    req.user = decoded;

    const role =
      decoded.role ||
      decoded.userRole ||
      decoded.accountRole ||
      decoded.type ||
      null;

    if (!role) {
      return res.status(403).json({
        success: false,
        error: "ADMIN_ROLE_REQUIRED",
        message: "Administrator privileges are required."
      });
    }

    const normalizedRole = String(role)
      .trim()
      .toLowerCase()
      .replace(/\s+/g, "_");

    if (!ADMIN_ROLES.includes(normalizedRole)) {
      return res.status(403).json({
        success: false,
        error: "ADMIN_ACCESS_DENIED",
        message: "You do not have administrator privileges."
      });
    }

    req.admin = {
      authenticated: true,
      role: normalizedRole,
      userId: decoded.userId || decoded.id || decoded.sub || null
    };

    return next();
  } catch (error) {
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({
        success: false,
        error: "TOKEN_EXPIRED",
        message: "The access token has expired."
      });
    }

    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({
        success: false,
        error: "INVALID_TOKEN",
        message: "The access token is invalid."
      });
    }

    console.error("Admin authentication error:", error);

    return res.status(500).json({
      success: false,
      error: "ADMIN_AUTHENTICATION_ERROR",
      message: "An unexpected authentication error occurred."
    });
  }
}

/* =========================================================
   SUPER ADMIN CHECK
   ========================================================= */

function requireSuperAdmin(req, res, next) {
  if (!req.admin || !req.admin.authenticated) {
    return res.status(401).json({
      success: false,
      error: "AUTHENTICATION_REQUIRED",
      message: "Administrator authentication is required."
    });
  }

  const role = req.admin.role;

  if (role !== "superadmin" && role !== "super_admin") {
    return res.status(403).json({
      success: false,
      error: "SUPER_ADMIN_REQUIRED",
      message: "Super administrator privileges are required."
    });
  }

  return next();
}

/* =========================================================
   EXPORTS
   ========================================================= */

module.exports = {
  adminAuth,
  requireSuperAdmin
};
