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
 * - JWT access tokens
 * - Refresh token management
 * - User sessions
 * - Login audit logging
 * - Default user role
 * - Logout
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

const REFRESH_TOKEN_EXPIRES_DAYS =
  Number(process.env.REFRESH_TOKEN_EXPIRES_DAYS) || 30;

const DEFAULT_USER_ROLE = "user";

const JWT_ISSUER = "worthapp";

const JWT_AUDIENCE = "worthapp-api";

/**
 * =========================================================
 * VALIDATION
 * =========================================================
 */

function normalizeEmail(email) {
  if (typeof email !== "string") {
    return "";
  }

  return email.trim().toLowerCase();
}

function validateEmail(email) {
  const normalizedEmail =
    normalizeEmail(email);

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
 */

const PASSWORD_KEY_LENGTH = 64;

const PASSWORD_SALT_LENGTH = 32;

const SCRYPT_OPTIONS = {
  N: 16384,
  r: 8,
  p: 1
};

function hashPassword(password) {
  return new Promise((resolve, reject) => {
    const salt = crypto.randomBytes(
      PASSWORD_SALT_LENGTH
    );

    crypto.scrypt(
      password,
      salt,
      PASSWORD_KEY_LENGTH,
      SCRYPT_OPTIONS,
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

    let salt;
    let storedKey;

    try {
      salt = Buffer.from(
        parts[1],
        "hex"
      );

      storedKey = Buffer.from(
        parts[2],
        "hex"
      );
    } catch (error) {
      resolve(false);
      return;
    }

    if (
      salt.length === 0 ||
      storedKey.length === 0
    ) {
      resolve(false);
      return;
    }

    crypto.scrypt(
      password,
      salt,
      storedKey.length,
      SCRYPT_OPTIONS,
      (error, derivedKey) => {
        if (error) {
          reject(error);
          return;
        }

        if (
          derivedKey.length !==
          storedKey.length
        ) {
          resolve(false);
          return;
        }

        resolve(
          crypto.timingSafeEqual(
            derivedKey,
            storedKey
          )
        );
      }
    );
  });
}

/**
 * =========================================================
 * JWT CONFIGURATION
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
 * ACCESS TOKEN
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
      role:
        user.role ||
        DEFAULT_USER_ROLE
    },
    JWT_SECRET,
    {
      expiresIn: JWT_EXPIRES_IN,
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE
    }
  );
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
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE
    }
  );
}

/**
 * =========================================================
 * REFRESH TOKEN HELPERS
 * =========================================================
 */

function generateRefreshToken() {
  return crypto.randomBytes(64).toString("hex");
}

function hashToken(token) {
  return crypto
    .createHash("sha256")
    .update(token)
    .digest("hex");
}

function getRefreshTokenExpiry() {
  const expiresAt = new Date();

  expiresAt.setDate(
    expiresAt.getDate() +
      REFRESH_TOKEN_EXPIRES_DAYS
  );

  return expiresAt;
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
 * CREATE USER PROFILE
 * =========================================================
 */

async function createUserProfile(userId) {
  await query(
    `
      INSERT INTO user_profiles (
        user_id
      )
      VALUES ($1)
      ON CONFLICT (user_id)
      DO NOTHING
    `,
    [userId]
  );
}

/**
 * =========================================================
 * CREATE DEFAULT USER ROLE
 * =========================================================
 */

async function createDefaultUserRole(userId) {
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
      userId,
      DEFAULT_USER_ROLE
    ]
  );
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
    const error = new Error(
      "A valid email address is required."
    );

    error.code = "AUTH_INVALID_EMAIL";

    throw error;
  }

  if (!validatePassword(password)) {
    const error = new Error(
      "Password must be between 8 and 128 characters."
    );

    error.code = "AUTH_INVALID_PASSWORD";

    throw error;
  }

  if (!validateDisplayName(displayName)) {
    const error = new Error(
      "Display name must be between 1 and 100 characters."
    );

    error.code = "AUTH_INVALID_DISPLAY_NAME";

    throw error;
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

  let user;

  try {
    const result = await query(
      `
        INSERT INTO users (
          email,
          password_hash,
          display_name,
          status,
          email_verified
        )
        VALUES (
          $1,
          $2,
          $3,
          'active',
          FALSE
        )
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

    user = result.rows[0];
  } catch (error) {
    if (
      error &&
      error.code === "23505"
    ) {
      const duplicateError =
        new Error(
          "An account with this email already exists."
        );

      duplicateError.code =
        "AUTH_EMAIL_ALREADY_EXISTS";

      throw duplicateError;
    }

    throw error;
  }

  await createUserProfile(user.id);

  await createDefaultUserRole(
    user.id
  );

  return {
    id: user.id,
    email: user.email,
    displayName:
      user.display_name,
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
 * CREATE USER SESSION
 * =========================================================
 */

async function createUserSession({
  userId,
  refreshToken,
  ipAddress = null,
  userAgent = null,
  deviceName = null
}) {
  const tokenHash =
    hashToken(refreshToken);

  const expiresAt =
    getRefreshTokenExpiry();

  const result = await query(
    `
      INSERT INTO user_sessions (
        user_id,
        session_token_hash,
        ip_address,
        user_agent,
        device_name,
        expires_at
      )
      VALUES (
        $1,
        $2,
        $3,
        $4,
        $5,
        $6
      )
      RETURNING
        id,
        expires_at,
        created_at
    `,
    [
      userId,
      tokenHash,
      ipAddress,
      userAgent,
      deviceName,
      expiresAt
    ]
  );

  return result.rows[0];
}

/**
 * =========================================================
 * CREATE REFRESH TOKEN RECORD
 * =========================================================
 */

async function createRefreshTokenRecord({
  userId,
  refreshToken
}) {
  const tokenHash =
    hashToken(refreshToken);

  const expiresAt =
    getRefreshTokenExpiry();

  const result = await query(
    `
      INSERT INTO refresh_tokens (
        user_id,
        token_hash,
        expires_at
      )
      VALUES (
        $1,
        $2,
        $3
      )
      RETURNING
        id,
        expires_at,
        created_at
    `,
    [
      userId,
      tokenHash,
      expiresAt
    ]
  );

  return result.rows[0];
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
  userAgent = null,
  deviceName = null
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

  if (
    !user ||
    !user.password_hash
  ) {
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
    role:
      user.role ||
      DEFAULT_USER_ROLE
  };

  const accessToken =
    createAccessToken(
      safeUser
    );

  const refreshToken =
    generateRefreshToken();

  await createRefreshTokenRecord({
    userId: user.id,
    refreshToken
  });

  await createUserSession({
    userId: user.id,
    refreshToken,
    ipAddress,
    userAgent,
    deviceName
  });

  return {
    user: safeUser,
    accessToken,
    refreshToken,
    tokenType: "Bearer",
    expiresIn: JWT_EXPIRES_IN,
    refreshTokenExpiresInDays:
      REFRESH_TOKEN_EXPIRES_DAYS
  };
}

/**
 * =========================================================
 * REFRESH ACCESS TOKEN
 * =========================================================
 */

async function refreshAccessToken(
  refreshToken
) {
  if (
    typeof refreshToken !== "string" ||
    !refreshToken.trim()
  ) {
    throw new Error(
      "Refresh token is required."
    );
  }

  const tokenHash =
    hashToken(refreshToken);

  const result = await query(
    `
      SELECT
        rt.id,
        rt.user_id,
        rt.expires_at,
        rt.revoked_at,
        u.email,
        u.display_name,
        u.status,
        u.email_verified,
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
      FROM refresh_tokens rt
      INNER JOIN users u
        ON u.id = rt.user_id
      WHERE rt.token_hash = $1
      LIMIT 1
    `,
    [
      tokenHash,
      DEFAULT_USER_ROLE
    ]
  );

  const tokenRecord =
    result.rows[0];

  if (!tokenRecord) {
    throw new Error(
      "Invalid refresh token."
    );
  }

  if (tokenRecord.revoked_at) {
    throw new Error(
      "Refresh token has been revoked."
    );
  }

  if (
    new Date(tokenRecord.expires_at)
      <= new Date()
  ) {
    throw new Error(
      "Refresh token has expired."
    );
  }

  if (
    tokenRecord.status !== "active"
  ) {
    throw new Error(
      "This account is not active."
    );
  }

  const user = {
    id: tokenRecord.user_id,
    email: tokenRecord.email,
    displayName:
      tokenRecord.display_name,
    status:
      tokenRecord.status,
    emailVerified:
      tokenRecord.email_verified,
    role:
      tokenRecord.role ||
      DEFAULT_USER_ROLE
  };

  const accessToken =
    createAccessToken(user);

  return {
    accessToken,
    tokenType: "Bearer",
    expiresIn: JWT_EXPIRES_IN,
    user
  };
}

/**
 * =========================================================
 * LOGOUT
 * =========================================================
 */

async function logoutUser(
  refreshToken
) {
  if (
    typeof refreshToken !== "string" ||
    !refreshToken.trim()
  ) {
    return {
      success: true
    };
  }

  const tokenHash =
    hashToken(refreshToken);

  await query(
    `
      UPDATE refresh_tokens
      SET revoked_at = NOW()
      WHERE token_hash = $1
        AND revoked_at IS NULL
    `,
    [tokenHash]
  );

  await query(
    `
      UPDATE user_sessions
      SET revoked_at = NOW()
      WHERE session_token_hash = $1
        AND revoked_at IS NULL
    `,
    [tokenHash]
  );

  return {
    success: true
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
 * SANITIZE USER
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

  refreshAccessToken,
  logoutUser,

  createUserSession,
  createRefreshTokenRecord,

  recordLoginAttempt,

  sanitizeUser
};
