"use strict";

/**
 * =========================================================
 * WORTHAPP
 * USER SERVICE
 *
 * File: services/userService.js
 *
 * Responsibilities:
 * - Read users from database
 * - Read user profiles
 * - Read user settings
 * - Create user profiles
 * - Update user profiles
 * - Update user settings
 * - Keep database operations outside controllers
 * =========================================================
 */

const {
  query
} = require("../database/connection");

/**
 * =========================================================
 * GET USER BY ID
 * =========================================================
 */

async function getUserById(userId) {
  if (!userId) {
    throw new Error(
      "User ID is required."
    );
  }

  const result = await query(
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

  return result.rows[0] || null;
}

/**
 * =========================================================
 * GET USER PROFILE
 * ========================================================= */

async function getUserProfile(userId) {
  if (!userId) {
    throw new Error(
      "User ID is required."
    );
  }

  const result = await query(
    `
    SELECT
      u.id,
      u.email,
      u.display_name,
      u.status,
      u.email_verified,
      u.created_at,
      u.updated_at,

      p.first_name,
      p.last_name,
      p.phone,
      p.country_code,
      p.preferred_language,
      p.timezone,
      p.avatar_url

    FROM users u

    LEFT JOIN user_profiles p
      ON p.user_id = u.id

    WHERE u.id = $1

    LIMIT 1
    `,
    [userId]
  );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * GET USER SETTINGS
 * ========================================================= */

async function getUserSettings(userId) {
  if (!userId) {
    throw new Error(
      "User ID is required."
    );
  }

  const result = await query(
    `
    SELECT
      id,
      user_id,
      preferred_language,
      timezone,
      theme,
      email_notifications,
      push_notifications,
      sms_notifications,
      marketing_notifications,
      privacy_profile_visibility,
      two_factor_enabled,
      metadata,
      created_at,
      updated_at

    FROM user_settings

    WHERE user_id = $1

    LIMIT 1
    `,
    [userId]
  );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * CREATE USER PROFILE
 * ========================================================= */

async function createUserProfile(
  userId,
  profile = {}
) {
  if (!userId) {
    throw new Error(
      "User ID is required."
    );
  }

  const {
    firstName = null,
    lastName = null,
    phone = null,
    countryCode = null,
    preferredLanguage = "en",
    timezone = null,
    avatarUrl = null
  } = profile;

  const result = await query(
    `
    INSERT INTO user_profiles (
      user_id,
      first_name,
      last_name,
      phone,
      country_code,
      preferred_language,
      timezone,
      avatar_url
    )

    VALUES (
      $1,
      $2,
      $3,
      $4,
      $5,
      $6,
      $7,
      $8
    )

    ON CONFLICT (user_id)
    DO UPDATE SET
      first_name = EXCLUDED.first_name,
      last_name = EXCLUDED.last_name,
      phone = EXCLUDED.phone,
      country_code = EXCLUDED.country_code,
      preferred_language = EXCLUDED.preferred_language,
      timezone = EXCLUDED.timezone,
      avatar_url = EXCLUDED.avatar_url,
      updated_at = NOW()

    RETURNING *
    `,
    [
      userId,
      firstName,
      lastName,
      phone,
      countryCode,
      preferredLanguage,
      timezone,
      avatarUrl
    ]
  );

  return result.rows[0];
}

/**
 * =========================================================
 * UPDATE USER PROFILE
 * ========================================================= */

async function updateUserProfile(
  userId,
  profile = {}
) {
  if (!userId) {
    throw new Error(
      "User ID is required."
    );
  }

  const existing =
    await getUserProfile(userId);

  if (!existing) {
    return null;
  }

  const firstName =
    profile.firstName !== undefined
      ? profile.firstName
      : existing.first_name;

  const lastName =
    profile.lastName !== undefined
      ? profile.lastName
      : existing.last_name;

  const phone =
    profile.phone !== undefined
      ? profile.phone
      : existing.phone;

  const countryCode =
    profile.countryCode !== undefined
      ? profile.countryCode
      : existing.country_code;

  const preferredLanguage =
    profile.preferredLanguage !== undefined
      ? profile.preferredLanguage
      : existing.preferred_language;

  const timezone =
    profile.timezone !== undefined
      ? profile.timezone
      : existing.timezone;

  const avatarUrl =
    profile.avatarUrl !== undefined
      ? profile.avatarUrl
      : existing.avatar_url;

  const result = await query(
    `
    INSERT INTO user_profiles (
      user_id,
      first_name,
      last_name,
      phone,
      country_code,
      preferred_language,
      timezone,
      avatar_url
    )

    VALUES (
      $1,
      $2,
      $3,
      $4,
      $5,
      $6,
      $7,
      $8
    )

    ON CONFLICT (user_id)
    DO UPDATE SET
      first_name = EXCLUDED.first_name,
      last_name = EXCLUDED.last_name,
      phone = EXCLUDED.phone,
      country_code = EXCLUDED.country_code,
      preferred_language = EXCLUDED.preferred_language,
      timezone = EXCLUDED.timezone,
      avatar_url = EXCLUDED.avatar_url,
      updated_at = NOW()

    RETURNING *
    `,
    [
      userId,
      firstName,
      lastName,
      phone,
      countryCode,
      preferredLanguage,
      timezone,
      avatarUrl
    ]
  );

  return result.rows[0];
}

/**
 * =========================================================
 * CREATE DEFAULT USER SETTINGS
 * ========================================================= */

async function createDefaultUserSettings(
  userId
) {
  if (!userId) {
    throw new Error(
      "User ID is required."
    );
  }

  const result = await query(
    `
    INSERT INTO user_settings (
      user_id
    )

    VALUES ($1)

    ON CONFLICT (user_id)
    DO UPDATE SET
      updated_at = NOW()

    RETURNING *
    `,
    [userId]
  );

  return result.rows[0];
}

/**
 * =========================================================
 * UPDATE USER SETTINGS
 * ========================================================= */

async function updateUserSettings(
  userId,
  settings = {}
) {
  if (!userId) {
    throw new Error(
      "User ID is required."
    );
  }

  const existing =
    await getUserSettings(userId);

  if (!existing) {
    return null;
  }

  const preferredLanguage =
    settings.preferredLanguage !== undefined
      ? settings.preferredLanguage
      : existing.preferred_language;

  const timezone =
    settings.timezone !== undefined
      ? settings.timezone
      : existing.timezone;

  const theme =
    settings.theme !== undefined
      ? settings.theme
      : existing.theme;

  const emailNotifications =
    settings.emailNotifications !== undefined
      ? settings.emailNotifications
      : existing.email_notifications;

  const pushNotifications =
    settings.pushNotifications !== undefined
      ? settings.pushNotifications
      : existing.push_notifications;

  const smsNotifications =
    settings.smsNotifications !== undefined
      ? settings.smsNotifications
      : existing.sms_notifications;

  const marketingNotifications =
    settings.marketingNotifications !== undefined
      ? settings.marketingNotifications
      : existing.marketing_notifications;

  const privacyProfileVisibility =
    settings.privacyProfileVisibility !== undefined
      ? settings.privacyProfileVisibility
      : existing.privacy_profile_visibility;

  const twoFactorEnabled =
    settings.twoFactorEnabled !== undefined
      ? settings.twoFactorEnabled
      : existing.two_factor_enabled;

  const metadata =
    settings.metadata !== undefined
      ? settings.metadata
      : existing.metadata;

  const result = await query(
    `
    UPDATE user_settings

    SET
      preferred_language = $2,
      timezone = $3,
      theme = $4,
      email_notifications = $5,
      push_notifications = $6,
      sms_notifications = $7,
      marketing_notifications = $8,
      privacy_profile_visibility = $9,
      two_factor_enabled = $10,
      metadata = $11,
      updated_at = NOW()

    WHERE user_id = $1

    RETURNING *
    `,
    [
      userId,
      preferredLanguage,
      timezone,
      theme,
      emailNotifications,
      pushNotifications,
      smsNotifications,
      marketingNotifications,
      privacyProfileVisibility,
      twoFactorEnabled,
      metadata
    ]
  );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * GET COMPLETE USER ACCOUNT
 * ========================================================= */

async function getCompleteUserAccount(
  userId
) {
  if (!userId) {
    throw new Error(
      "User ID is required."
    );
  }

  const result = await query(
    `
    SELECT
      u.id,
      u.email,
      u.display_name,
      u.status,
      u.email_verified,
      u.created_at,
      u.updated_at,
      u.last_login_at,

      p.first_name,
      p.last_name,
      p.phone,
      p.country_code,
      p.preferred_language AS profile_language,
      p.timezone AS profile_timezone,
      p.avatar_url,

      s.preferred_language AS settings_language,
      s.timezone AS settings_timezone,
      s.theme,
      s.email_notifications,
      s.push_notifications,
      s.sms_notifications,
      s.marketing_notifications,
      s.privacy_profile_visibility,
      s.two_factor_enabled,
      s.metadata AS settings_metadata

    FROM users u

    LEFT JOIN user_profiles p
      ON p.user_id = u.id

    LEFT JOIN user_settings s
      ON s.user_id = u.id

    WHERE u.id = $1

    LIMIT 1
    `,
    [userId]
  );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * MODULE EXPORTS
 * =========================================================
 */

module.exports = {
  getUserById,

  getUserProfile,

  getUserSettings,

  createUserProfile,

  updateUserProfile,

  createDefaultUserSettings,

  updateUserSettings,

  getCompleteUserAccount
};
