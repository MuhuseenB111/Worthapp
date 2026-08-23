"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * ROLE AUTHORIZATION MIDDLEWARE
 *
 * File: middleware/roles.js
 *
 * Responsibilities:
 * - Load user roles from PostgreSQL
 * - Attach roles to authenticated request
 * - Check required roles
 * - Protect admin/moderator/seller/private resources
 * =========================================================
 */

const {
  pool
} = require("../database/connection");

/**
 * =========================================================
 * ROLE DEFINITIONS
 * =========================================================
 *
 * These are the initial Worthapp roles.
 *
 * We can expand them later without breaking
 * the existing authentication system.
 */

const ROLES = Object.freeze({
  USER: "user",
  ADMIN: "admin",
  SUPER_ADMIN: "super_admin",
  MODERATOR: "moderator",
  SELLER: "seller",
  BUYER: "buyer",
  SUPPORT: "support",
  FINANCE: "finance",
  CONTENT_MANAGER: "content_manager"
});

/**
 * =========================================================
 * VALIDATE ROLE NAME
 * =========================================================
 */

function isValidRole(role) {
  return (
    typeof role === "string" &&
    role.trim().length > 0
  );
}

/**
 * =========================================================
 * LOAD USER ROLES
 * =========================================================
 */

async function loadUserRoles(userId) {
  if (!userId) {
    throw new Error(
      "User ID is required to load roles."
    );
  }

  const result = await pool.query(
    `
    SELECT role
    FROM user_roles
    WHERE user_id = $1
    ORDER BY role ASC
    `,
    [userId]
  );

  return result.rows.map(
    (row) => row.role
  );
}

/**
 * =========================================================
 * ATTACH USER ROLES
 * =========================================================
 */

async function attachUserRoles(
  request,
  response,
  next
) {
  try {
    /**
     * -------------------------------------------------------
     * AUTHENTICATION CHECK
     * -------------------------------------------------------
     */

    if (!request.authenticatedUser) {
      return response.status(401).json({
        success: false,
        error: "Authentication required.",
        code: "AUTH_REQUIRED"
      });
    }

    /**
     * -------------------------------------------------------
     * LOAD ROLES
     * -------------------------------------------------------
     */

    const roles =
      await loadUserRoles(
        request.authenticatedUser.id
      );

    /**
     * -------------------------------------------------------
     * ATTACH ROLES TO REQUEST
     * -------------------------------------------------------
     */

    request.userRoles =
      Object.freeze([...roles]);

    return next();
  } catch (error) {
    console.error(
      "Worthapp role loading error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Unable to load user roles.",
      code: "ROLE_LOAD_ERROR"
    });
  }
}

/**
 * =========================================================
 * HAS ROLE
 * =========================================================
 */

function hasRole(
  request,
  role
) {
  if (!isValidRole(role)) {
    return false;
  }

  if (!Array.isArray(request.userRoles)) {
    return false;
  }

  return request.userRoles.includes(
    role.trim()
  );
}

/**
 * =========================================================
 * HAS ANY ROLE
 * =========================================================
 *
 * Returns true when the authenticated user
 * has at least one of the supplied roles.
 */

function hasAnyRole(
  request,
  roles = []
) {
  if (!Array.isArray(roles)) {
    return false;
  }

  return roles.some(
    (role) =>
      hasRole(request, role)
  );
}

/**
 * =========================================================
 * HAS ALL ROLES
 * =========================================================
 *
 * Returns true only when the authenticated user
 * has every supplied role.
 */

function hasAllRoles(
  request,
  roles = []
) {
  if (!Array.isArray(roles)) {
    return false;
  }

  return roles.every(
    (role) =>
      hasRole(request, role)
  );
}

/**
 * =========================================================
 * REQUIRE ROLE
 * =========================================================
 *
 * Example:
 *
 * router.get(
 *   "/admin",
 *   authenticate,
 *   attachUserRoles,
 *   requireRole(ROLES.ADMIN),
 *   controller
 * );
 */

function requireRole(...requiredRoles) {
  return function roleMiddleware(
    request,
    response,
    next
  ) {
    /**
     * -------------------------------------------------------
     * AUTHENTICATION CHECK
     * -------------------------------------------------------
     */

    if (!request.authenticatedUser) {
      return response.status(401).json({
        success: false,
        error: "Authentication required.",
        code: "AUTH_REQUIRED"
      });
    }

    /**
     * -------------------------------------------------------
     * VALIDATE REQUIRED ROLES
     * -------------------------------------------------------
     */

    const validRoles =
      requiredRoles.filter(
        isValidRole
      );

    if (validRoles.length === 0) {
      return response.status(500).json({
        success: false,
        error:
          "No valid authorization role was configured.",
        code: "ROLE_CONFIGURATION_ERROR"
      });
    }

    /**
     * -------------------------------------------------------
     * CHECK USER ROLES
     * -------------------------------------------------------
     */

    if (
      !hasAnyRole(
        request,
        validRoles
      )
    ) {
      return response.status(403).json({
        success: false,
        error:
          "You do not have permission to access this resource.",
        code: "ROLE_ACCESS_DENIED"
      });
    }

    return next();
  };
}

/**
 * =========================================================
 * REQUIRE ALL ROLES
 * =========================================================
 */

function requireAllRoles(...requiredRoles) {
  return function allRolesMiddleware(
    request,
    response,
    next
  ) {
    /**
     * -------------------------------------------------------
     * AUTHENTICATION CHECK
     * -------------------------------------------------------
     */

    if (!request.authenticatedUser) {
      return response.status(401).json({
        success: false,
        error: "Authentication required.",
        code: "AUTH_REQUIRED"
      });
    }

    /**
     * -------------------------------------------------------
     * VALIDATE ROLES
     * -------------------------------------------------------
     */

    const validRoles =
      requiredRoles.filter(
        isValidRole
      );

    if (validRoles.length === 0) {
      return response.status(500).json({
        success: false,
        error:
          "No valid authorization roles were configured.",
        code: "ROLE_CONFIGURATION_ERROR"
      });
    }

    /**
     * -------------------------------------------------------
     * CHECK ALL ROLES
     * -------------------------------------------------------
     */

    if (
      !hasAllRoles(
        request,
        validRoles
      )
    ) {
      return response.status(403).json({
        success: false,
        error:
          "You do not have all required roles.",
        code: "ROLE_ACCESS_DENIED"
      });
    }

    return next();
  };
}

/**
 * =========================================================
 * ADMIN AUTHORIZATION
 * =========================================================
 *
 * Convenience middleware for admin-only routes.
 */

const requireAdmin =
  requireRole(
    ROLES.ADMIN,
    ROLES.SUPER_ADMIN
  );

/**
 * =========================================================
 * SUPER ADMIN AUTHORIZATION
 * =========================================================
 */

const requireSuperAdmin =
  requireRole(
    ROLES.SUPER_ADMIN
  );

/**
 * =========================================================
 * MODERATOR AUTHORIZATION
 * =========================================================
 */

const requireModerator =
  requireRole(
    ROLES.MODERATOR,
    ROLES.ADMIN,
    ROLES.SUPER_ADMIN
  );

/**
 * =========================================================
 * SELLER AUTHORIZATION
 * =========================================================
 */

const requireSeller =
  requireRole(
    ROLES.SELLER
  );

/**
 * =========================================================
 * SUPPORT AUTHORIZATION
 * =========================================================
 */

const requireSupport =
  requireRole(
    ROLES.SUPPORT,
    ROLES.ADMIN,
    ROLES.SUPER_ADMIN
  );

/**
 * =========================================================
 * EXPORTS
 * =========================================================
 */

module.exports = {
  ROLES,

  loadUserRoles,

  attachUserRoles,

  hasRole,

  hasAnyRole,

  hasAllRoles,

  requireRole,

  requireAllRoles,

  requireAdmin,

  requireSuperAdmin,

  requireModerator,

  requireSeller,

  requireSupport
};
