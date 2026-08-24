"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * USER CONTROLLER
 *
 * File: controllers/userController.js
 *
 * Responsibilities:
 * - Return current authenticated user
 * - Return public user profile
 * - Update user profile
 * - Sanitize user data
 * - Connect user routes to PostgreSQL
 * =========================================================
 */

const {
  pool
} = require("../database/connection");

/**
 * =========================================================
 * SANITIZE USER
 * =========================================================
 *
 * Prevent sensitive database fields from being
 * returned to the client.
 */

function sanitizeUser(user) {
  if (!user || typeof user !== "object") {
    return null;
  }

  return {
    id: user.id,
    email: user.email,
    displayName:
      user.display_name ??
      user.displayName ??
      null,

    status:
      user.status ?? null,

    emailVerified:
      user.email_verified ??
      false,

    createdAt:
      user.created_at ?? null,

    updatedAt:
      user.updated_at ?? null,

    lastLoginAt:
      user.last_login_at ?? null
  };
}

/**
 * =========================================================
 * GET CURRENT USER
 * =========================================================
 *
 * GET /api/v1/users/me
 *
 * Authentication middleware will attach:
 *
 * request.authenticatedUser
 */

async function getCurrentUser(
  request,
  response
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
        error:
          "Authentication required.",
        code:
          "AUTH_REQUIRED"
      });
    }

    /**
     * -------------------------------------------------------
     * RETURN AUTHENTICATED USER
     * -------------------------------------------------------
     */

    return response.status(200).json({
      success: true,

      user:
        sanitizeUser(
          request.authenticatedUser
        )
    });
  } catch (error) {
    console.error(
      "Worthapp get current user error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Unable to load current user.",
      code:
        "USER_ME_ERROR"
    });
  }
}

/**
 * =========================================================
 * GET USER PROFILE
 * =========================================================
 *
 * GET /api/v1/users/:userId
 */

async function getUserProfile(
  request,
  response
) {
  try {
    const {
      userId
    } = request.params;

    /**
     * -------------------------------------------------------
     * VALIDATE USER ID
     * -------------------------------------------------------
     */

    if (!userId) {
      return response.status(400).json({
        success: false,
        error:
          "User ID is required.",
        code:
          "USER_ID_REQUIRED"
      });
    }

    /**
     * -------------------------------------------------------
     * LOAD USER
     * -------------------------------------------------------
     */

    const result =
      await pool.query(
        `
        SELECT
          id,
          email,
          display_name,
          status,
          email_verified,
          created_at,
          updated_at,
          last_login_at
        FROM users
        WHERE id = $1
        LIMIT 1
        `,
        [userId]
      );

    /**
     * -------------------------------------------------------
     * USER NOT FOUND
     * -------------------------------------------------------
     */

    if (result.rows.length === 0) {
      return response.status(404).json({
        success: false,
        error:
          "User was not found.",
        code:
          "USER_NOT_FOUND"
      });
    }

    /**
     * -------------------------------------------------------
     * RESPONSE
     * -------------------------------------------------------
     */

    return response.status(200).json({
      success: true,

      user:
        sanitizeUser(
          result.rows[0]
        )
    });
  } catch (error) {
    console.error(
      "Worthapp get user profile error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Unable to load user profile.",
      code:
        "USER_PROFILE_ERROR"
    });
  }
}

/**
 * =========================================================
 * UPDATE USER PROFILE
 * =========================================================
 *
 * PATCH /api/v1/users/:userId
 *
 * Currently supports:
 * - displayName
 *
 * More profile fields will be added progressively.
 */

async function updateUserProfile(
  request,
  response
) {
  try {
    const {
      userId
    } = request.params;

    /**
     * -------------------------------------------------------
     * AUTHENTICATION CHECK
     * -------------------------------------------------------
     */

    if (!request.authenticatedUser) {
      return response.status(401).json({
        success: false,
        error:
          "Authentication required.",
        code:
          "AUTH_REQUIRED"
      });
    }

    /**
     * -------------------------------------------------------
     * USER OWNERSHIP CHECK
     * -------------------------------------------------------
     *
     * A normal authenticated user can only
     * update their own profile.
     *
     * Admin authorization will be expanded later.
     */

    if (
      String(
        request.authenticatedUser.id
      ) !== String(userId)
    ) {
      return response.status(403).json({
        success: false,
        error:
          "You can only update your own profile.",
        code:
          "USER_PROFILE_ACCESS_DENIED"
      });
    }

    /**
     * -------------------------------------------------------
     * REQUEST BODY
     * -------------------------------------------------------
     */

    const body =
      request.body || {};

    const displayName =
      typeof body.displayName === "string"
        ? body.displayName.trim()
        : null;

    /**
     * -------------------------------------------------------
     * VALIDATE DISPLAY NAME
     * -------------------------------------------------------
     */

    if (
      displayName !== null &&
      (
        displayName.length < 2 ||
        displayName.length > 100
      )
    ) {
      return response.status(400).json({
        success: false,
        error:
          "Display name must be between 2 and 100 characters.",
        code:
          "USER_DISPLAY_NAME_INVALID"
      });
    }

    /**
     * -------------------------------------------------------
     * CHECK UPDATE DATA
     * -------------------------------------------------------
     */

    if (displayName === null) {
      return response.status(400).json({
        success: false,
        error:
          "No supported profile fields were provided.",
        code:
          "USER_NO_UPDATE_FIELDS"
      });
    }

    /**
     * -------------------------------------------------------
     * UPDATE DATABASE
     * -------------------------------------------------------
     */

    const result =
      await pool.query(
        `
        UPDATE users
        SET
          display_name = $1,
          updated_at = NOW()
        WHERE id = $2
        RETURNING
          id,
          email,
          display_name,
          status,
          email_verified,
          created_at,
          updated_at,
          last_login_at
        `,
        [
          displayName,
          userId
        ]
      );

    /**
     * -------------------------------------------------------
     * USER NOT FOUND
     * -------------------------------------------------------
     */

    if (result.rows.length === 0) {
      return response.status(404).json({
        success: false,
        error:
          "User was not found.",
        code:
          "USER_NOT_FOUND"
      });
    }

    /**
     * -------------------------------------------------------
     * RESPONSE
     * -------------------------------------------------------
     */

    return response.status(200).json({
      success: true,

      message:
        "User profile updated successfully.",

      user:
        sanitizeUser(
          result.rows[0]
        )
    });
  } catch (error) {
    console.error(
      "Worthapp update user profile error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Unable to update user profile.",
      code:
        "USER_UPDATE_ERROR"
    });
  }
}

/**
 * =========================================================
 * MODULE EXPORTS
 * =========================================================
 */

module.exports = {
  sanitizeUser,
  getCurrentUser,
  getUserProfile,
  updateUserProfile
};
