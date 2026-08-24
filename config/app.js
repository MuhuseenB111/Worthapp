"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * APPLICATION CONFIGURATION
 *
 * File: config/app.js
 *
 * Responsibilities:
 * - Central application configuration
 * - Environment configuration
 * - Server configuration
 * - Security defaults
 * - Privacy principles
 * - Global platform settings
 *
 * IMPORTANT:
 * - Do NOT store DATABASE_URL here.
 * - Do NOT store passwords here.
 * - Do NOT store JWT secrets here.
 * - Do NOT store API keys or private credentials here.
 *
 * Secrets will be loaded securely from environment variables
 * through the appropriate configuration/service layer.
 * =========================================================
 */

/**
 * =========================================================
 * APPLICATION CONFIGURATION
 * =========================================================
 */

const appConfig = Object.freeze({
  /**
   * -------------------------------------------------------
   * APPLICATION IDENTITY
   * -------------------------------------------------------
   */

  name: "Worthapp",

  version: "1.0.0",

  /**
   * -------------------------------------------------------
   * ENVIRONMENT
   * -------------------------------------------------------
   *
   * development
   * test
   * production
   */

  environment:
    process.env.NODE_ENV || "development",

  /**
   * -------------------------------------------------------
   * SERVER
   * -------------------------------------------------------
   */

  server: Object.freeze({
    host:
      process.env.HOST || "0.0.0.0",

    port:
      Number(process.env.PORT) || 3000
  }),

  /**
   * -------------------------------------------------------
   * API
   * -------------------------------------------------------
   */

  api: Object.freeze({
    prefix:
      process.env.API_PREFIX || "/api/v1"
  }),

  /**
   * -------------------------------------------------------
   * SECURITY
   * -------------------------------------------------------
   *
   * These are safe application defaults.
   * Detailed security implementation will be added
   * progressively in the Security stage.
   */

  security: Object.freeze({
    trustProxy: false,

    sendDetailedErrors: false
  }),

  /**
   * -------------------------------------------------------
   * PRIVACY
   * -------------------------------------------------------
   *
   * Worthapp is designed as a privacy-first platform.
   */

  privacy: Object.freeze({
    privacyFirst: true,

    userConsentRequired: true
  }),

  /**
   * -------------------------------------------------------
   * PLATFORM
   * -------------------------------------------------------
   *
   * Worthapp is designed as a global platform.
   *
   * multilingual:
   * The architecture must support many languages,
   * not only English and Hausa.
   */

  platform: Object.freeze({
    global: true,

    multilingual: true,

    aiEnabled: true
  })
});

/**
 * =========================================================
 * MODULE EXPORT
 * =========================================================
 *
 * Worthapp currently uses CommonJS because package.json
 * contains:
 *
 * "type": "commonjs"
 *
 * Therefore we use module.exports instead of
 * export default.
 * =========================================================
 */

module.exports = appConfig;
