"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * VALIDATION MIDDLEWARE
 *
 * File: middleware/validation.js
 *
 * Responsibilities:
 * - Validate email addresses
 * - Validate phone numbers
 * - Validate usernames
 * - Validate passwords
 * - Validate strings
 * - Validate integers
 * - Validate dates
 * - Validate required request fields
 * - Create validation errors
 * - Send validation responses
 * =========================================================
 */

/**
 * =========================================================
 * VALIDATION PATTERNS
 * =========================================================
 */

const EMAIL_PATTERN =
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const PHONE_PATTERN =
  /^\+?[1-9]\d{7,14}$/;

const USERNAME_PATTERN =
  /^[a-zA-Z0-9._-]{3,30}$/;

/**
 * =========================================================
 * PASSWORD CONFIGURATION
 * =========================================================
 */

const PASSWORD_MIN_LENGTH = 12;

const PASSWORD_MAX_LENGTH = 128;

/**
 * =========================================================
 * PLAIN OBJECT CHECK
 * =========================================================
 */

function isPlainObject(value) {
  if (
    value === null ||
    typeof value !== "object"
  ) {
    return false;
  }

  const prototype =
    Object.getPrototypeOf(value);

  return (
    prototype === Object.prototype ||
    prototype === null
  );
}

/**
 * =========================================================
 * EMAIL VALIDATION
 * =========================================================
 */

function isValidEmail(email) {
  return (
    typeof email === "string" &&
    EMAIL_PATTERN.test(
      email.trim()
    )
  );
}

/**
 * =========================================================
 * PHONE VALIDATION
 * =========================================================
 */

function isValidPhoneNumber(phone) {
  return (
    typeof phone === "string" &&
    PHONE_PATTERN.test(
      phone.trim()
    )
  );
}

/**
 * =========================================================
 * USERNAME VALIDATION
 * =========================================================
 */

function isValidUsername(username) {
  return (
    typeof username === "string" &&
    USERNAME_PATTERN.test(
      username.trim()
    )
  );
}

/**
 * =========================================================
 * PASSWORD VALIDATION
 * =========================================================
 */

function isValidPassword(password) {
  return (
    typeof password === "string" &&
    password.length >=
      PASSWORD_MIN_LENGTH &&
    password.length <=
      PASSWORD_MAX_LENGTH
  );
}

/**
 * =========================================================
 * STRING VALIDATION
 * =========================================================
 */

function isValidString(
  value,
  {
    minLength = 1,
    maxLength = 255,
    trim = true
  } = {}
) {
  if (typeof value !== "string") {
    return false;
  }

  const normalizedValue = trim
    ? value.trim()
    : value;

  return (
    normalizedValue.length >=
      minLength &&
    normalizedValue.length <=
      maxLength
  );
}

/**
 * =========================================================
 * INTEGER VALIDATION
 * =========================================================
 */

function isValidInteger(
  value,
  {
    min = Number.MIN_SAFE_INTEGER,
    max = Number.MAX_SAFE_INTEGER
  } = {}
) {
  return (
    Number.isInteger(value) &&
    value >= min &&
    value <= max
  );
}

/**
 * =========================================================
 * DATE VALIDATION
 * =========================================================
 */

function isValidDateString(value) {
  if (
    typeof value !== "string" ||
    !value.trim()
  ) {
    return false;
  }

  const date = new Date(value);

  return !Number.isNaN(
    date.getTime()
  );
}

/**
 * =========================================================
 * REQUIRED FIELD VALIDATION
 * =========================================================
 */

function validateRequiredFields(
  data,
  requiredFields
) {
  if (!isPlainObject(data)) {
    return {
      valid: false,
      errors: [
        "Request data must be an object."
      ]
    };
  }

  if (!Array.isArray(requiredFields)) {
    throw new TypeError(
      "requiredFields must be an array."
    );
  }

  const errors = [];

  for (
    const field of requiredFields
  ) {
    if (
      typeof field !== "string" ||
      !field.trim()
    ) {
      continue;
    }

    const value = data[field];

    if (
      value === undefined ||
      value === null ||
      (
        typeof value === "string" &&
        value.trim() === ""
      )
    ) {
      errors.push(
        `${field} is required.`
      );
    }
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

/**
 * =========================================================
 * CREATE VALIDATION ERROR
 * =========================================================
 */

function createValidationError(
  errors
) {
  const error = new Error(
    "Validation failed."
  );

  error.code =
    "VALIDATION_ERROR";

  error.statusCode = 400;

  error.details =
    Array.isArray(errors)
      ? [...errors]
      : [];

  return error;
}

/**
 * =========================================================
 * SEND VALIDATION ERROR
 * =========================================================
 *
 * Express-compatible response helper.
 */

function sendValidationError(
  response,
  errors
) {
  return response.status(400).json({
    success: false,
    error: "Validation failed.",
    code: "VALIDATION_ERROR",
    details:
      Array.isArray(errors)
        ? errors
        : []
  });
}

/**
 * =========================================================
 * MODULE EXPORTS
 * =========================================================
 *
 * Worthapp uses CommonJS.
 * =========================================================
 */

module.exports = {
  EMAIL_PATTERN,
  PHONE_PATTERN,
  USERNAME_PATTERN,

  PASSWORD_MIN_LENGTH,
  PASSWORD_MAX_LENGTH,

  isPlainObject,
  isValidEmail,
  isValidPhoneNumber,
  isValidUsername,
  isValidPassword,
  isValidString,
  isValidInteger,
  isValidDateString,

  validateRequiredFields,

  createValidationError,
  sendValidationError
};
