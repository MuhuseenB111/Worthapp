const EMAIL_PATTERN =
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const PHONE_PATTERN =
  /^\+?[1-9]\d{7,14}$/;

const USERNAME_PATTERN =
  /^[a-zA-Z0-9._-]{3,30}$/;

const PASSWORD_MIN_LENGTH = 12;
const PASSWORD_MAX_LENGTH = 128;

function isPlainObject(value) {
  if (value === null || typeof value !== "object") {
    return false;
  }

  const prototype = Object.getPrototypeOf(value);

  return prototype === Object.prototype ||
    prototype === null;
}

function isValidEmail(email) {
  return (
    typeof email === "string" &&
    EMAIL_PATTERN.test(email.trim())
  );
}

function isValidPhoneNumber(phone) {
  return (
    typeof phone === "string" &&
    PHONE_PATTERN.test(phone.trim())
  );
}

function isValidUsername(username) {
  return (
    typeof username === "string" &&
    USERNAME_PATTERN.test(username.trim())
  );
}

function isValidPassword(password) {
  return (
    typeof password === "string" &&
    password.length >= PASSWORD_MIN_LENGTH &&
    password.length <= PASSWORD_MAX_LENGTH
  );
}

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
    normalizedValue.length >= minLength &&
    normalizedValue.length <= maxLength
  );
}

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

function isValidDateString(value) {
  if (typeof value !== "string" || !value.trim()) {
    return false;
  }

  const date = new Date(value);

  return !Number.isNaN(date.getTime());
}

function validateRequiredFields(
  data,
  requiredFields
) {
  if (!isPlainObject(data)) {
    return {
      valid: false,
      errors: ["Request data must be an object."]
    };
  }

  if (!Array.isArray(requiredFields)) {
    throw new TypeError(
      "requiredFields must be an array."
    );
  }

  const errors = [];

  for (const field of requiredFields) {
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
      (typeof value === "string" &&
        value.trim() === "")
    ) {
      errors.push(`${field} is required.`);
    }
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

function createValidationError(errors) {
  const error = new Error(
    "Validation failed."
  );

  error.code = "VALIDATION_ERROR";
  error.statusCode = 400;
  error.details = Array.isArray(errors)
    ? [...errors]
    : [];

  return error;
}

function sendValidationError(response, errors) {
  response.writeHead(400, {
    "Content-Type":
      "application/json; charset=utf-8",
    "Cache-Control": "no-store",
    "X-Content-Type-Options": "nosniff"
  });

  response.end(
    JSON.stringify({
      success: false,
      error: "Validation failed.",
      details: Array.isArray(errors)
        ? errors
        : []
    })
  );
}

export {
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
