"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * AUTHENTICATION SERVICE
 *
 * File: services/authService.js
 *
 * Responsibilities:
 * - User registration
 * - Password hashing
 * - Password verification
 * - User lookup
 * - Login authentication
 * - JWT generation
 * - Default user role creation
 * =========================================================
 */

const crypto = require("crypto");
const jwt = require("jsonwebtoken");

const {
  query
} = require("../database/connection");

/**
 * =========================================================
 * CONFIGURATION
 * =========================================================
 */

const JWT_SECRET = process.env.JWT_SECRET;

const JWT_EXPIRES_IN =
  process.env.JWT_EXPIRES_IN || "1h";

const DEFAULT_USER_ROLE = "user";

/**
 * =========================================================
 * VALIDATION HELPERS
 * =========================================================
 */

function normalizeEmail(email) {
  if (typeof email !== "string") {
    return "";
  }

  return email.trim().toLowerCase();
}

function validateEmail(email) {
  const normalizedEmail = normalizeEmail(email);

  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(
    normalizedEmail
  );
}

function validatePassword(password) {
  return (
    typeof password === "string" &&
    password.length >= 8 &&
    password.length <= 128
  );
}

function validateDisplayName(displayName) {
  if (displayName === undefined) {
    return true;
  }

  return (
    typeof displayName === "string" &&
    displayName.trim().length >= 1 &&
    displayName.trim().length <= 100
  );
}

/**
 * =========================================================
 * PASSWORD HASHING
 * =========================================================
 *
 * Node.js built-in scrypt is used.
 *
 * We never store plain-text passwords.
 * =========================================================
 */

const PASSWORD_KEY_LENGTH = 64;

const PASSWORD_SALT_LENGTH = 32;

function hashPassword(password) {
  return new Promise((resolve, reject) => {
    const salt = crypto.randomBytes(
      PASSWORD_SALT_LENGTH
    );

    crypto.scrypt(
      password,
      salt,
      PASSWORD_KEY_LENGTH,
      {
        N: 16384,
        r: 8,
        p: 1
      },
      (error, derivedKey) => {
        if (error) {
          reject(error);
          return;
        }

        const passwordHash = [
          "scrypt",
          salt.toString("hex"),
          derivedKey.toString("hex")
        ].join("$");

        resolve(passwordHash);
      }
    );
  });
}

/**
 * =========================================================
 * PASSWORD VERIFICATION
 * =========================================================
 */

function verifyPassword(password, storedHash) {
  return new Promise((resolve, reject) => {
    if (
      typeof password !== "string" ||
      typeof storedHash !== "string"
    ) {
      resolve(false);
      return;
    }

    const parts = storedHash.split("$");

    if (
      parts.length !== 3 ||
      parts[0] !== "scrypt"
    ) {
      resolve(false);
      return;
    }

    const salt = Buffer.from(
      parts[1],
      "hex"
    );

    const storedKey = Buffer.from(
      parts[2],
      "hex"
    );

    crypto.scrypt(
      password,
      salt,
      storedKey.length,
      {
        N: 16384,
        r: 8,
        p: 1
      },
      (error, derivedKey) => {
        if (error) {
          reject(error);
          return;
        }

        if (
          derivedKey.length !== storedKey.length
        ) {
          resolve(false);
          return;
        }

        const isValid =
          crypto.timingSafeEqual(
            derivedKey,
            storedKey
          );

        resolve(isValid);
      }
    );
  });
}

/**
 * =========================================================
 * JWT CONFIGURATION CHECK
 * =========================================================
 */

function ensureJwtConfiguration() {
  if (
    !JWT_SECRET ||
    typeof JWT_SECRET !== "string" ||
    JWT_SECRET.length < 32
  ) {
    throw new Error(
      "JWT_SECRET must be configured and contain at least 32 characters."
    );
  }
}

/**
 * =========================================================
 * CREATE ACCESS TOKEN
 * =========================================================
 */

function createAccessToken(user) {
  ensureJwtConfiguration();

  if (!user || !user.id) {
    throw new TypeError(
      "A valid user is required to create an access token."
    );
  }

  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      role: user.role || DEFAULT_USER_ROLE
    },
    JWT_SECRET,
    {
      expiresIn: JWT_EXPIRES_IN,
      issuer: "worthapp",
      audience: "worthapp-api"
    }
  );
}

/**
 * =========================================================
 * FIND USER BY EMAIL
 * =========================================================
 */

async function findUserByEmail(email) {
  const normalizedEmail =
    normalizeEmail(email);

  const result = await query(
    `
      SELECT
        u.id,
        u.email,
        u.password_hash,
        u.display_name,
        u.status,
        u.email_verified,
        u.created_at,
        u.updated_at,
        u.last_login_at,
        COALESCE(
          (
            SELECT ur.role
            FROM user_roles ur
            WHERE ur.user_id = u.id
            ORDER BY ur.created_at ASC
            LIMIT 1
          ),
          $2
        ) AS role
      FROM users u
      WHERE u.email = $1
      LIMIT 1
    `,
    [
      normalizedEmail,
      DEFAULT_USER_ROLE
    ]
  );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * FIND USER BY ID
 * =========================================================
 */

async function findUserById(userId) {
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
        COALESCE(
          (
            SELECT ur.role
            FROM user_roles ur
            WHERE ur.user_id = u.id
            ORDER BY ur.created_at ASC
            LIMIT 1
          ),
          $2
        ) AS role
      FROM users u
      WHERE u.id = $1
      LIMIT 1
    `,
    [
      userId,
      DEFAULT_USER_ROLE
    ]
  );

  return result.rows[0] || null;
}

/**
 * =========================================================
 * REGISTER USER
 * =========================================================
 */

async function registerUser({
  email,
  password,
  displayName
}) {
  const normalizedEmail =
    normalizeEmail(email);

  if (!validateEmail(normalizedEmail)) {
    throw new Error(
      "A valid email address is required."
    );
  }

  if (!validatePassword(password)) {
    throw new Error(
      "Password must be between 8 and 128 characters."
    );
  }

  if (!validateDisplayName(displayName)) {
    throw new Error(
      "Display name must be between 1 and 100 characters."
    );
  }

  const existingUser =
    await findUserByEmail(
      normalizedEmail
    );

  if (existingUser) {
    const error = new Error(
      "An account with this email already exists."
    );

    error.code =
      "AUTH_EMAIL_ALREADY_EXISTS";

    throw error;
  }

  const passwordHash =
    await hashPassword(password);

  const clientResult = await query(
    `
      INSERT INTO users (
        email,
        password_hash,
        display_name,
        status,
        email_verified
      )
      VALUES ($1, $2, $3, 'active', FALSE)
      RETURNING
        id,
        email,
        display_name,
        status,
        email_verified,
        created_at,
        updated_at
    `,
    [
      normalizedEmail,
      passwordHash,
      displayName
        ? displayName.trim()
        : null
    ]
  );

  const user =
    clientResult.rows[0];

  await query(
    `
      INSERT INTO user_profiles (
        user_id
      )
      VALUES ($1)
      ON CONFLICT (user_id)
      DO NOTHING
    `,
    [user.id]
  );

  await query(
    `
      INSERT INTO user_roles (
        user_id,
        role
      )
      VALUES ($1, $2)
      ON CONFLICT (user_id, role)
      DO NOTHING
    `,
    [
      user.id,
      DEFAULT_USER_ROLE
    ]
  );

  return {
    id: user.id,
    email: user.email,
    displayName: user.display_name,
    status: user.status,
    emailVerified:
      user.email_verified,
    createdAt: user.created_at,
    updatedAt: user.updated_at,
    role: DEFAULT_USER_ROLE
  };
}

/**
 * =========================================================
 * LOGIN USER
 * =========================================================
 */

async function loginUser({
  email,
  password,
  ipAddress = null,
  userAgent = null
}) {
  const normalizedEmail =
    normalizeEmail(email);

  if (!validateEmail(normalizedEmail)) {
    throw new Error(
      "Invalid email or password."
    );
  }

  if (
    typeof password !== "string" ||
    password.length === 0
  ) {
    throw new Error(
      "Invalid email or password."
    );
  }

  const user =
    await findUserByEmail(
      normalizedEmail
    );

  if (!user || !user.password_hash) {
    await recordLoginAttempt({
      email: normalizedEmail,
      ipAddress,
      userAgent,
      successful: false,
      failureReason:
        "INVALID_CREDENTIALS"
    });

    throw new Error(
      "Invalid email or password."
    );
  }

  if (user.status !== "active") {
    await recordLoginAttempt({
      userId: user.id,
      email: normalizedEmail,
      ipAddress,
      userAgent,
      successful: false,
      failureReason:
        "ACCOUNT_NOT_ACTIVE"
    });

    throw new Error(
      "This account is not active."
    );
  }

  const passwordValid =
    await verifyPassword(
      password,
      user.password_hash
    );

  if (!passwordValid) {
    await recordLoginAttempt({
      userId: user.id,
      email: normalizedEmail,
      ipAddress,
      userAgent,
      successful: false,
      failureReason:
        "INVALID_CREDENTIALS"
    });

    throw new Error(
      "Invalid email or password."
    );
  }

  await query(
    `
      UPDATE users
      SET
        last_login_at = NOW(),
        updated_at = NOW()
      WHERE id = $1
    `,
    [user.id]
  );

  await recordLoginAttempt({
    userId: user.id,
    email: normalizedEmail,
    ipAddress,
    userAgent,
    successful: true,
    failureReason: null
  });

  const safeUser = {
    id: user.id,
    email: user.email,
    displayName:
      user.display_name,
    status: user.status,
    emailVerified:
      user.email_verified,
    role: user.role
  };

  const accessToken =
    createAccessToken(
      safeUser
    );

  return {
    user: safeUser,
    accessToken,
    tokenType: "Bearer",
    expiresIn: JWT_EXPIRES_IN
  };
}

/**
 * =========================================================
 * RECORD LOGIN ATTEMPT
 * =========================================================
 */

async function recordLoginAttempt({
  userId = null,
  email = null,
  ipAddress = null,
  userAgent = null,
  successful = false,
  failureReason = null
}) {
  try {
    await query(
      `
        INSERT INTO login_attempts (
          user_id,
          email,
          ip_address,
          user_agent,
          successful,
          failure_reason
        )
        VALUES (
          $1,
          $2,
          $3,
          $4,
          $5,
          $6
        )
      `,
      [
        userId,
        email,
        ipAddress,
        userAgent,
        successful,
        failureReason
      ]
    );
  } catch (error) {
    console.error(
      "Worthapp login audit error:",
      error
    );
  }
}

/**
 * =========================================================
 * VERIFY ACCESS TOKEN
 * =========================================================
 */

function verifyAccessToken(token) {
  ensureJwtConfiguration();

  if (
    typeof token !== "string" ||
    !token.trim()
  ) {
    throw new Error(
      "Access token is required."
    );
  }

  return jwt.verify(
    token,
    JWT_SECRET,
    {
      issuer: "worthapp",
      audience: "worthapp-api"
    }
  );
}

/**
 * =========================================================
 * PUBLIC USER DATA
 * =========================================================
 */

function sanitizeUser(user) {
  if (!user) {
    return null;
  }

  return {
    id: user.id,
    email: user.email,
    displayName:
      user.display_name ||
      user.displayName ||
      null,
    status: user.status,
    emailVerified:
      user.email_verified ??
      user.emailVerified ??
      false,
    role:
      user.role ||
      DEFAULT_USER_ROLE,
    createdAt:
      user.created_at ||
      user.createdAt ||
      null,
    updatedAt:
      user.updated_at ||
      user.updatedAt ||
      null,
    lastLoginAt:
      user.last_login_at ||
      user.lastLoginAt ||
      null
  };
}

/**
 * =========================================================
 * MODULE EXPORTS
 * =========================================================
 */

module.exports = {
  normalizeEmail,
  validateEmail,
  validatePassword,

  hashPassword,
  verifyPassword,

  findUserByEmail,
  findUserById,

  registerUser,
  loginUser,

  createAccessToken,
  verifyAccessToken,

  recordLoginAttempt,

  sanitizeUser
};
