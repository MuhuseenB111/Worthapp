"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * USER SERVICE
 *
 * File: services/userService.js
 *
 * Responsibilities:
 * - Read users
 * - Read user profiles
 * - Read user settings
 * - Create/update user profiles
 * - Create/update user settings
 * - Return complete account information
 * - Keep database operations outside controllers
 * =========================================================
 */

const {
  query
} = require("../database/connection");

/**
 * =========================================================
 * VALIDATE USER ID
 * =========================================================
 */

function validateUserId(userId) {
  if (
    userId === undefined ||
    userId === null ||
    String(userId).trim() === ""
  ) {
    throw new Error(
      "User ID is required."
    );
  }

  return String(userId).trim();
}

/**
 * =========================================================
 * GET USER BY ID
 * =========================================================
 */

async function getUserById(userId) {
  const id =
    validateUserId(userId);

  const result =
    await query(
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
      [id]
    );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * GET USER PROFILE
 * =========================================================
 */

async function getUserProfile(userId) {
  const id =
    validateUserId(userId);

  const result =
    await query(
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

        p.id AS profile_id,
        p.first_name,
        p.last_name,
        p.phone,
        p.country_code,
        p.preferred_language,
        p.timezone,
        p.avatar_url,
        p.created_at AS profile_created_at,
        p.updated_at AS profile_updated_at

      FROM users u

      LEFT JOIN user_profiles p
        ON p.user_id = u.id

      WHERE u.id = $1

      LIMIT 1
      `,
      [id]
    );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * GET USER SETTINGS
 * =========================================================
 */

async function getUserSettings(userId) {
  const id =
    validateUserId(userId);

  const result =
    await query(
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
      [id]
    );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * CREATE USER PROFILE
 * =========================================================
 *
 * Creates the profile if it does not exist.
 *
 * If the profile already exists, it updates it.
 */

async function createUserProfile(
  userId,
  profile = {}
) {
  const id =
    validateUserId(userId);

  if (
    !profile ||
    typeof profile !== "object" ||
    Array.isArray(profile)
  ) {
    throw new TypeError(
      "Profile data must be an object."
    );
  }

  const firstName =
    profile.firstName !== undefined
      ? profile.firstName
      : null;

  const lastName =
    profile.lastName !== undefined
      ? profile.lastName
      : null;

  const phone =
    profile.phone !== undefined
      ? profile.phone
      : null;

  const countryCode =
    profile.countryCode !== undefined
      ? profile.countryCode
      : null;

  const preferredLanguage =
    profile.preferredLanguage !== undefined
      ? profile.preferredLanguage
      : "en";

  const timezone =
    profile.timezone !== undefined
      ? profile.timezone
      : null;

  const avatarUrl =
    profile.avatarUrl !== undefined
      ? profile.avatarUrl
      : null;

  const result =
    await query(
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
        first_name =
          EXCLUDED.first_name,

        last_name =
          EXCLUDED.last_name,

        phone =
          EXCLUDED.phone,

        country_code =
          EXCLUDED.country_code,

        preferred_language =
          EXCLUDED.preferred_language,

        timezone =
          EXCLUDED.timezone,

        avatar_url =
          EXCLUDED.avatar_url,

        updated_at =
          NOW()

      RETURNING
        id,
        user_id,
        first_name,
        last_name,
        phone,
        country_code,
        preferred_language,
        timezone,
        avatar_url,
        created_at,
        updated_at
      `,
      [
        id,
        firstName,
        lastName,
        phone,
        countryCode,
        preferredLanguage,
        timezone,
        avatarUrl
      ]
    );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * UPDATE USER PROFILE
 * =========================================================
 *
 * Uses existing values for fields that were not supplied.
 *
 * This prevents PATCH requests from accidentally
 * deleting existing profile information.
 */

async function updateUserProfile(
  userId,
  profile = {}
) {
  const id =
    validateUserId(userId);

  if (
    !profile ||
    typeof profile !== "object" ||
    Array.isArray(profile)
  ) {
    throw new TypeError(
      "Profile data must be an object."
    );
  }

  const existing =
    await getUserProfile(id);

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

  const result =
    await query(
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
        first_name =
          EXCLUDED.first_name,

        last_name =
          EXCLUDED.last_name,

        phone =
          EXCLUDED.phone,

        country_code =
          EXCLUDED.country_code,

        preferred_language =
          EXCLUDED.preferred_language,

        timezone =
          EXCLUDED.timezone,

        avatar_url =
          EXCLUDED.avatar_url,

        updated_at =
          NOW()

      RETURNING
        id,
        user_id,
        first_name,
        last_name,
        phone,
        country_code,
        preferred_language,
        timezone,
        avatar_url,
        created_at,
        updated_at
      `,
      [
        id,
        firstName,
        lastName,
        phone,
        countryCode,
        preferredLanguage,
        timezone,
        avatarUrl
      ]
    );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * CREATE DEFAULT USER SETTINGS
 * =========================================================
 */

async function createDefaultUserSettings(
  userId
) {
  const id =
    validateUserId(userId);

  const result =
    await query(
      `
      INSERT INTO user_settings (
        user_id
      )

      VALUES ($1)

      ON CONFLICT (user_id)

      DO UPDATE SET
        updated_at = NOW()

      RETURNING
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
      `,
      [id]
    );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * UPDATE USER SETTINGS
 * =========================================================
 */

async function updateUserSettings(
  userId,
  settings = {}
) {
  const id =
    validateUserId(userId);

  if (
    !settings ||
    typeof settings !== "object" ||
    Array.isArray(settings)
  ) {
    throw new TypeError(
      "Settings data must be an object."
    );
  }

  /**
   * -------------------------------------------------------
   * MAKE SURE SETTINGS RECORD EXISTS
   * -------------------------------------------------------
   */

  let existing =
    await getUserSettings(id);

  if (!existing) {
    existing =
      await createDefaultUserSettings(id);
  }

  /**
   * -------------------------------------------------------
   * PREPARE VALUES
   * -------------------------------------------------------
   */

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

  /**
   * -------------------------------------------------------
   * UPDATE DATABASE
   * -------------------------------------------------------
   */

  const result =
    await query(
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

      RETURNING
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
      `,
      [
        id,
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
 * =========================================================
 *
 * Returns:
 * - User account
 * - Profile
 * - Settings
 *
 * Sensitive fields such as password_hash are NOT returned.
 */

async function getCompleteUserAccount(
  userId
) {
  const id =
    validateUserId(userId);

  const result =
    await query(
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

        p.id AS profile_id,
        p.first_name,
        p.last_name,
        p.phone,
        p.country_code,
        p.preferred_language AS profile_language,
        p.timezone AS profile_timezone,
        p.avatar_url,

        s.id AS settings_id,
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
      [id]
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
