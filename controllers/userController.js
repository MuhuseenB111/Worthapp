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
 * - Return user profile
 * - Update user profile
 * - Return user settings
 * - Update user settings
 * - Connect HTTP requests to userService
 *
 * IMPORTANT:
 * Database operations belong to:
 * services/userService.js
 * =========================================================
 */

const {
  getUserById,
  getUserProfile,
  updateUserProfile,
  getUserSettings,
  updateUserSettings,
  createDefaultUserSettings,
  getCompleteUserAccount
} = require("../services/userService");

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
      user.status ??
      null,

    emailVerified:
      user.email_verified ??
      false,

    createdAt:
      user.created_at ??
      null,

    updatedAt:
      user.updated_at ??
      null,

    lastLoginAt:
      user.last_login_at ??
      null
  };
}

/**
 * =========================================================
 * GET CURRENT USER
 * =========================================================
 *
 * GET /api/v1/users/me
 *
 * Authentication middleware attaches:
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
     * LOAD FRESH USER DATA
     * -------------------------------------------------------
     */

    const user =
      await getUserById(
        request.authenticatedUser.id
      );

    if (!user) {
      return response.status(404).json({
        success: false,
        error:
          "Authenticated user was not found.",
        code:
          "AUTHENTICATED_USER_NOT_FOUND"
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
        sanitizeUser(user)
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

async function getUserProfileController(
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
     * LOAD PROFILE THROUGH SERVICE
     * -------------------------------------------------------
     */

    const profile =
      await getUserProfile(
        userId
      );

    if (!profile) {
      return response.status(404).json({
        success: false,
        error:
          "User profile was not found.",
        code:
          "USER_PROFILE_NOT_FOUND"
      });
    }

    /**
     * -------------------------------------------------------
     * RESPONSE
     * -------------------------------------------------------
     */

    return response.status(200).json({
      success: true,

      profile: {
        user:
          sanitizeUser(profile),

        profile: {
          id:
            profile.profile_id ??
            null,

          firstName:
            profile.first_name ??
            null,

          lastName:
            profile.last_name ??
            null,

          phone:
            profile.phone ??
            null,

          countryCode:
            profile.country_code ??
            null,

          preferredLanguage:
            profile.preferred_language ??
            null,

          timezone:
            profile.timezone ??
            null,

          avatarUrl:
            profile.avatar_url ??
            null
        }
      }
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
 */

async function updateUserProfileController(
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

    /**
     * -------------------------------------------------------
     * UPDATE THROUGH SERVICE
     * -------------------------------------------------------
     */

    const updatedProfile =
      await updateUserProfile(
        userId,
        body
      );

    if (!updatedProfile) {
      return response.status(404).json({
        success: false,
        error:
          "User profile was not found.",
        code:
          "USER_PROFILE_NOT_FOUND"
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

      profile: {
        id:
          updatedProfile.id,

        userId:
          updatedProfile.user_id,

        firstName:
          updatedProfile.first_name,

        lastName:
          updatedProfile.last_name,

        phone:
          updatedProfile.phone,

        countryCode:
          updatedProfile.country_code,

        preferredLanguage:
          updatedProfile.preferred_language,

        timezone:
          updatedProfile.timezone,

        avatarUrl:
          updatedProfile.avatar_url,

        updatedAt:
          updatedProfile.updated_at
      }
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
 * GET USER SETTINGS
 * =========================================================
 *
 * GET /api/v1/users/:userId/settings
 */

async function getSettings(
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
     * OWNERSHIP CHECK
     * -------------------------------------------------------
     */

    if (
      String(
        request.authenticatedUser.id
      ) !== String(userId)
    ) {
      return response.status(403).json({
        success: false,
        error:
          "You can only access your own settings.",
        code:
          "USER_SETTINGS_ACCESS_DENIED"
      });
    }

    /**
     * -------------------------------------------------------
     * LOAD SETTINGS
     * -------------------------------------------------------
     */

    let settings =
      await getUserSettings(
        userId
      );

    /**
     * -------------------------------------------------------
     * CREATE DEFAULT SETTINGS
     * -------------------------------------------------------
     */

    if (!settings) {
      settings =
        await createDefaultUserSettings(
          userId
        );
    }

    /**
     * -------------------------------------------------------
     * RESPONSE
     * -------------------------------------------------------
     */

    return response.status(200).json({
      success: true,

      settings
    });

  } catch (error) {
    console.error(
      "Worthapp get user settings error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Unable to load user settings.",
      code:
        "USER_SETTINGS_ERROR"
    });
  }
}

/**
 * =========================================================
 * UPDATE USER SETTINGS
 * =========================================================
 *
 * PATCH /api/v1/users/:userId/settings
 */

async function updateSettings(
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
     * OWNERSHIP CHECK
     * -------------------------------------------------------
     */

    if (
      String(
        request.authenticatedUser.id
      ) !== String(userId)
    ) {
      return response.status(403).json({
        success: false,
        error:
          "You can only update your own settings.",
        code:
          "USER_SETTINGS_ACCESS_DENIED"
      });
    }

    /**
     * -------------------------------------------------------
     * UPDATE SETTINGS
     * -------------------------------------------------------
     */

    const settings =
      await updateUserSettings(
        userId,
        request.body || {}
      );

    if (!settings) {
      return response.status(404).json({
        success: false,
        error:
          "User settings could not be updated.",
        code:
          "USER_SETTINGS_NOT_FOUND"
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
        "User settings updated successfully.",

      settings
    });

  } catch (error) {
    console.error(
      "Worthapp update user settings error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Unable to update user settings.",
      code:
        "USER_SETTINGS_UPDATE_ERROR"
    });
  }
}

/**
 * =========================================================
 * GET COMPLETE USER ACCOUNT
 * =========================================================
 *
 * GET /api/v1/users/:userId/account
 */

async function getCompleteAccount(
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
     * OWNERSHIP CHECK
     * -------------------------------------------------------
     */

    if (
      String(
        request.authenticatedUser.id
      ) !== String(userId)
    ) {
      return response.status(403).json({
        success: false,
        error:
          "You can only access your own account.",
        code:
          "USER_ACCOUNT_ACCESS_DENIED"
      });
    }

    /**
     * -------------------------------------------------------
     * LOAD COMPLETE ACCOUNT
     * -------------------------------------------------------
     */

    const account =
      await getCompleteUserAccount(
        userId
      );

    if (!account) {
      return response.status(404).json({
        success: false,
        error:
          "User account was not found.",
        code:
          "USER_ACCOUNT_NOT_FOUND"
      });
    }

    /**
     * -------------------------------------------------------
     * RESPONSE
     * -------------------------------------------------------
     */

    return response.status(200).json({
      success: true,

      account: {
        user:
          sanitizeUser(account),

        profile: {
          id:
            account.profile_id ??
            null,

          firstName:
            account.first_name ??
            null,

          lastName:
            account.last_name ??
            null,

          phone:
            account.phone ??
            null,

          countryCode:
            account.country_code ??
            null,

          preferredLanguage:
            account.profile_language ??
            null,

          timezone:
            account.profile_timezone ??
            null,

          avatarUrl:
            account.avatar_url ??
            null
        },

        settings: {
          id:
            account.settings_id ??
            null,

          preferredLanguage:
            account.settings_language ??
            null,

          timezone:
            account.settings_timezone ??
            null,

          theme:
            account.theme ??
            null,

          emailNotifications:
            account.email_notifications ??
            false,

          pushNotifications:
            account.push_notifications ??
            false,

          smsNotifications:
            account.sms_notifications ??
            false,

          marketingNotifications:
            account.marketing_notifications ??
            false,

          privacyProfileVisibility:
            account.privacy_profile_visibility ??
            null,

          twoFactorEnabled:
            account.two_factor_enabled ??
            false,

          metadata:
            account.settings_metadata ??
            null
        }
      }
    });

  } catch (error) {
    console.error(
      "Worthapp get complete user account error:",
      error
    );

    return response.status(500).json({
      success: false,
      error:
        "Unable to load complete user account.",
      code:
        "USER_ACCOUNT_ERROR"
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

  getUserProfile:
    getUserProfileController,

  updateUserProfile:
    updateUserProfileController,

  getSettings,

  updateSettings,

  getCompleteAccount
};
