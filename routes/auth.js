"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * AUTHENTICATION ROUTES
 *
 * File: routes/auth.js
 *
 * Handles:
 * - Authentication status
 * - User registration
 * - User login
 * - Access token verification
 * - Token refresh
 * - User logout
 *
 * Connected to:
 * - PostgreSQL database
 * - users
 * - user_profiles
 * - user_roles
 * - user_sessions
 * - refresh_tokens
 * - login_attempts
 * =========================================================
 */

const express = require("express");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");

const { pool } = require("../database/connection");

const router = express.Router();

/**
 * =========================================================
 * CONFIGURATION
 * =========================================================
 */

const JWT_SECRET = process.env.JWT_SECRET;

const ACCESS_TOKEN_EXPIRES_IN =
  process.env.JWT_EXPIRES_IN || "15m";

const REFRESH_TOKEN_DAYS = 30;

/**
 * =========================================================
 * SECURITY CONFIGURATION
 * =========================================================
 */

const PASSWORD_MIN_LENGTH = 8;

/**
 * =========================================================
 * HELPER: HASH PASSWORD
 * =========================================================
 *
 * Node.js built-in scrypt is used.
 * No extra password hashing package is required.
 */

function hashPassword(password) {
  return new Promise((resolve, reject) => {
    const salt = crypto.randomBytes(16).toString("hex");

    crypto.scrypt(
      password,
      salt,
      64,
      {
        N: 16384,
        r: 8,
        p: 1
      },
      (error, derivedKey) => {
        if (error) {
          return reject(error);
        }

        resolve(
          `scrypt$${salt}$${derivedKey.toString("hex")}`
        );
      }
    );
  });
}

/**
 * =========================================================
 * HELPER: VERIFY PASSWORD
 * =========================================================
 */

function verifyPassword(password, storedHash) {
  return new Promise((resolve, reject) => {
    try {
      const parts = storedHash.split("$");

      if (parts.length !== 3 || parts[0] !== "scrypt") {
        return resolve(false);
      }

      const salt = parts[1];
      const storedKey = Buffer.from(parts[2], "hex");

      crypto.scrypt(
        password,
        salt,
        64,
        {
          N: 16384,
          r: 8,
          p: 1
        },
        (error, derivedKey) => {
          if (error) {
            return reject(error);
          }

          if (storedKey.length !== derivedKey.length) {
            return resolve(false);
          }

          resolve(
            crypto.timingSafeEqual(
              storedKey,
              derivedKey
            )
          );
        }
      );
    } catch (error) {
      reject(error);
    }
  });
}

/**
 * =========================================================
 * HELPER: HASH TOKEN
 * =========================================================
 */

function hashToken(token) {
  return crypto
    .createHash("sha256")
    .update(token)
    .digest("hex");
}

/**
 * =========================================================
 * HELPER: CREATE ACCESS TOKEN
 * =========================================================
 */

function createAccessToken(user) {
  if (!JWT_SECRET) {
    throw new Error(
      "JWT_SECRET environment variable is not configured."
    );
  }

  return jwt.sign(
    {
      sub: user.id,
      email: user.email
    },
    JWT_SECRET,
    {
      expiresIn: ACCESS_TOKEN_EXPIRES_IN,
      issuer: "worthapp",
      audience: "worthapp-api"
    }
  );
}

/**
 * =========================================================
 * HELPER: CREATE REFRESH TOKEN
 * =========================================================
 */

function createRefreshToken() {
  return crypto.randomBytes(64).toString("hex");
}

/**
 * =========================================================
 * HELPER: CREATE SESSION TOKEN
 * =========================================================
 */

function createSessionToken() {
  return crypto.randomBytes(48).toString("hex");
}

/**
 * =========================================================
 * HELPER: REFRESH TOKEN EXPIRATION
 * =========================================================
 */

function getRefreshExpiration() {
  const expiration = new Date();

  expiration.setDate(
    expiration.getDate() + REFRESH_TOKEN_DAYS
  );

  return expiration;
}

/**
 * =========================================================
 * AUTHENTICATION STATUS
 * =========================================================
 */

router.get("/status", (req, res) => {
  res.status(200).json({
    success: true,
    service: "Worthapp Authentication",
    status: "available",
    database: "connected through authentication module",
    timestamp: new Date().toISOString()
  });
});

/**
 * =========================================================
 * REGISTER
 * =========================================================
 */

router.post("/register", async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      email,
      password,
      displayName,
      firstName,
      lastName,
      phone,
      countryCode,
      preferredLanguage,
      timezone
    } = req.body;

    /**
     * -------------------------------------------------------
     * BASIC VALIDATION
     * -------------------------------------------------------
     */

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: "Email and password are required.",
        code: "AUTH_REQUIRED_FIELDS"
      });
    }

    const normalizedEmail =
      String(email).trim().toLowerCase();

    if (!normalizedEmail.includes("@")) {
      return res.status(400).json({
        success: false,
        error: "Please provide a valid email address.",
        code: "AUTH_INVALID_EMAIL"
      });
    }

    if (String(password).length < PASSWORD_MIN_LENGTH) {
      return res.status(400).json({
        success: false,
        error:
          "Password must contain at least 8 characters.",
        code: "AUTH_WEAK_PASSWORD"
      });
    }

    /**
     * -------------------------------------------------------
     * CHECK JWT CONFIGURATION
     * -------------------------------------------------------
     */

    if (!JWT_SECRET) {
      return res.status(500).json({
        success: false,
        error: "Authentication server configuration is incomplete.",
        code: "AUTH_JWT_SECRET_MISSING"
      });
    }

    /**
     * -------------------------------------------------------
     * CHECK EXISTING USER
     * -------------------------------------------------------
     */

    const existingUser = await client.query(
      `
      SELECT id
      FROM users
      WHERE email = $1
      LIMIT 1
      `,
      [normalizedEmail]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        error: "An account with this email already exists.",
        code: "AUTH_EMAIL_EXISTS"
      });
    }

    /**
     * -------------------------------------------------------
     * HASH PASSWORD
     * -------------------------------------------------------
     */

    const passwordHash = await hashPassword(
      String(password)
    );

    /**
     * -------------------------------------------------------
     * START DATABASE TRANSACTION
     * -------------------------------------------------------
     */

    await client.query("BEGIN");

    /**
     * -------------------------------------------------------
     * CREATE USER
     * -------------------------------------------------------
     */

    const userResult = await client.query(
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
        created_at
      `,
      [
        normalizedEmail,
        passwordHash,
        displayName
          ? String(displayName).trim()
          : null
      ]
    );

    const user = userResult.rows[0];

    /**
     * -------------------------------------------------------
     * CREATE USER PROFILE
     * -------------------------------------------------------
     */

    await client.query(
      `
      INSERT INTO user_profiles (
        user_id,
        first_name,
        last_name,
        phone,
        country_code,
        preferred_language,
        timezone
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      `,
      [
        user.id,
        firstName || null,
        lastName || null,
        phone || null,
        countryCode || null,
        preferredLanguage || "en",
        timezone || null
      ]
    );

    /**
     * -------------------------------------------------------
     * DEFAULT USER ROLE
     * -------------------------------------------------------
     */

    await client.query(
      `
      INSERT INTO user_roles (
        user_id,
        role
      )
      VALUES ($1, 'user')
      ON CONFLICT (user_id, role)
      DO NOTHING
      `,
      [user.id]
    );

    /**
     * -------------------------------------------------------
     * AUDIT LOG
     * -------------------------------------------------------
     */

    await client.query(
      `
      INSERT INTO audit_logs (
        user_id,
        action,
        resource_type,
        resource_id,
        metadata
      )
      VALUES (
        $1,
        'user.register',
        'user',
        $1,
        $2
      )
      `,
      [
        user.id,
        JSON.stringify({
          email: user.email
        })
      ]
    );

    /**
     * -------------------------------------------------------
     * COMMIT
     * -------------------------------------------------------
     */

    await client.query("COMMIT");

    /**
     * -------------------------------------------------------
     * RESPONSE
     * -------------------------------------------------------
     */

    return res.status(201).json({
      success: true,
      message: "Worthapp account created successfully.",
      user: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        status: user.status,
        emailVerified: user.email_verified,
        createdAt: user.created_at
      }
    });
  } catch (error) {
    await client.query("ROLLBACK");

    console.error(
      "Worthapp registration error:",
      error
    );

    return res.status(500).json({
      success: false,
      error: "Unable to create account.",
      code: "AUTH_REGISTER_ERROR"
    });
  } finally {
    client.release();
  }
});

/**
 * =========================================================
 * LOGIN
 * =========================================================
 */

router.post("/login", async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      email,
      password
    } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: "Email and password are required.",
        code: "AUTH_REQUIRED_FIELDS"
      });
    }

    if (!JWT_SECRET) {
      return res.status(500).json({
        success: false,
        error: "Authentication server configuration is incomplete.",
        code: "AUTH_JWT_SECRET_MISSING"
      });
    }

    const normalizedEmail =
      String(email).trim().toLowerCase();

    /**
     * -------------------------------------------------------
     * FIND USER
     * -------------------------------------------------------
     */

    const userResult = await client.query(
      `
      SELECT
        id,
        email,
        password_hash,
        display_name,
        status,
        email_verified
      FROM users
      WHERE email = $1
      LIMIT 1
      `,
      [normalizedEmail]
    );

    /**
     * -------------------------------------------------------
     * INVALID USER
     * -------------------------------------------------------
     */

    if (userResult.rows.length === 0) {
      await client.query(
        `
        INSERT INTO login_attempts (
          email,
          successful,
          failure_reason
        )
        VALUES ($1, FALSE, 'invalid_credentials')
        `,
        [normalizedEmail]
      );

      return res.status(401).json({
        success: false,
        error: "Invalid email or password.",
        code: "AUTH_INVALID_CREDENTIALS"
      });
    }

    const user = userResult.rows[0];

    /**
     * -------------------------------------------------------
     * ACCOUNT STATUS
     * -------------------------------------------------------
     */

    if (user.status !== "active") {
      await client.query(
        `
        INSERT INTO login_attempts (
          user_id,
          email,
          successful,
          failure_reason
        )
        VALUES ($1, $2, FALSE, $3)
        `,
        [
          user.id,
          user.email,
          `account_${user.status}`
        ]
      );

      return res.status(403).json({
        success: false,
        error: "This account is not currently active.",
        code: "AUTH_ACCOUNT_NOT_ACTIVE"
      });
    }

    /**
     * -------------------------------------------------------
     * VERIFY PASSWORD
     * -------------------------------------------------------
     */

    const passwordValid =
      await verifyPassword(
        String(password),
        user.password_hash
      );

    if (!passwordValid) {
      await client.query(
        `
        INSERT INTO login_attempts (
          user_id,
          email,
          successful,
          failure_reason
        )
        VALUES ($1, $2, FALSE, 'invalid_password')
        `,
        [
          user.id,
          user.email
        ]
      );

      return res.status(401).json({
        success: false,
        error: "Invalid email or password.",
        code: "AUTH_INVALID_CREDENTIALS"
      });
    }

    /**
     * -------------------------------------------------------
     * CREATE TOKENS
     * -------------------------------------------------------
     */

    const accessToken =
      createAccessToken(user);

    const refreshToken =
      createRefreshToken();

    const sessionToken =
      createSessionToken();

    const refreshTokenHash =
      hashToken(refreshToken);

    const sessionTokenHash =
      hashToken(sessionToken);

    const refreshExpiresAt =
      getRefreshExpiration();

    /**
     * -------------------------------------------------------
     * START TRANSACTION
     * -------------------------------------------------------
     */

    await client.query("BEGIN");

    /**
     * -------------------------------------------------------
     * SAVE SESSION
     * -------------------------------------------------------
     */

    await client.query(
      `
      INSERT INTO user_sessions (
        user_id,
        session_token_hash,
        expires_at
      )
      VALUES ($1, $2, $3)
      `,
      [
        user.id,
        sessionTokenHash,
        refreshExpiresAt
      ]
    );

    /**
     * -------------------------------------------------------
     * SAVE REFRESH TOKEN
     * -------------------------------------------------------
     */

    await client.query(
      `
      INSERT INTO refresh_tokens (
        user_id,
        token_hash,
        expires_at
      )
      VALUES ($1, $2, $3)
      `,
      [
        user.id,
        refreshTokenHash,
        refreshExpiresAt
      ]
    );

    /**
     * -------------------------------------------------------
     * UPDATE LAST LOGIN
     * -------------------------------------------------------
     */

    await client.query(
      `
      UPDATE users
      SET last_login_at = NOW(),
          updated_at = NOW()
      WHERE id = $1
      `,
      [user.id]
    );

    /**
     * -------------------------------------------------------
     * LOGIN AUDIT
     * -------------------------------------------------------
     */

    await client.query(
      `
      INSERT INTO login_attempts (
        user_id,
        email,
        successful
      )
      VALUES ($1, $2, TRUE)
      `,
      [
        user.id,
        user.email
      ]
    );

    await client.query(
      `
      INSERT INTO audit_logs (
        user_id,
        action,
        resource_type,
        resource_id
      )
      VALUES (
        $1,
        'user.login',
        'user',
        $1
      )
      `,
      [user.id]
    );

    /**
     * -------------------------------------------------------
     * COMMIT
     * -------------------------------------------------------
     */

    await client.query("COMMIT");

    /**
     * -------------------------------------------------------
     * RESPONSE
     * -------------------------------------------------------
     */

    return res.status(200).json({
      success: true,
      message: "Login successful.",
      tokens: {
        accessToken,
        refreshToken,
        tokenType: "Bearer",
        expiresIn: ACCESS_TOKEN_EXPIRES_IN
      },
      sessionToken,
      user: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        status: user.status,
        emailVerified: user.email_verified
      }
    });
  } catch (error) {
    await client.query("ROLLBACK");

    console.error(
      "Worthapp login error:",
      error
    );

    return res.status(500).json({
      success: false,
      error: "Unable to login.",
      code: "AUTH_LOGIN_ERROR"
    });
  } finally {
    client.release();
  }
});

/**
 * =========================================================
 * REFRESH ACCESS TOKEN
 * =========================================================
 */

router.post("/refresh", async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      refreshToken
    } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        error: "Refresh token is required.",
        code: "AUTH_REFRESH_TOKEN_REQUIRED"
      });
    }

    if (!JWT_SECRET) {
      return res.status(500).json({
        success: false,
        error: "Authentication server configuration is incomplete.",
        code: "AUTH_JWT_SECRET_MISSING"
      });
    }

    const tokenHash =
      hashToken(refreshToken);

    /**
     * -------------------------------------------------------
     * FIND VALID REFRESH TOKEN
     * -------------------------------------------------------
     */

    const tokenResult = await client.query(
      `
      SELECT
        rt.id,
        rt.user_id,
        rt.expires_at,
        u.email,
        u.display_name,
        u.status,
        u.email_verified
      FROM refresh_tokens rt
      INNER JOIN users u
        ON u.id = rt.user_id
      WHERE rt.token_hash = $1
        AND rt.revoked_at IS NULL
        AND rt.expires_at > NOW()
      LIMIT 1
      `,
      [tokenHash]
    );

    if (tokenResult.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: "Invalid or expired refresh token.",
        code: "AUTH_INVALID_REFRESH_TOKEN"
      });
    }

    const user = tokenResult.rows[0];

    if (user.status !== "active") {
      return res.status(403).json({
        success: false,
        error: "This account is not active.",
        code: "AUTH_ACCOUNT_NOT_ACTIVE"
      });
    }

    /**
     * -------------------------------------------------------
     * CREATE NEW ACCESS TOKEN
     * -------------------------------------------------------
     */

    const accessToken =
      createAccessToken(user);

    return res.status(200).json({
      success: true,
      message: "Access token refreshed successfully.",
      tokens: {
        accessToken,
        tokenType: "Bearer",
        expiresIn: ACCESS_TOKEN_EXPIRES_IN
      }
    });
  } catch (error) {
    console.error(
      "Worthapp refresh token error:",
      error
    );

    return res.status(500).json({
      success: false,
      error: "Unable to refresh access token.",
      code: "AUTH_REFRESH_ERROR"
    });
  } finally {
    client.release();
  }
});

/**
 * =========================================================
 * GET CURRENT USER
 * =========================================================
 */

router.get("/me", async (req, res) => {
  try {
    if (!JWT_SECRET) {
      return res.status(500).json({
        success: false,
        error: "Authentication server configuration is incomplete.",
        code: "AUTH_JWT_SECRET_MISSING"
      });
    }

    const authorization =
      req.headers.authorization;

    if (!authorization) {
      return res.status(401).json({
        success: false,
        error: "Authorization token is required.",
        code: "AUTH_TOKEN_REQUIRED"
      });
    }

    const parts =
      authorization.split(" ");

    if (
      parts.length !== 2 ||
      parts[0] !== "Bearer"
    ) {
      return res.status(401).json({
        success: false,
        error: "Invalid authorization format.",
        code: "AUTH_INVALID_AUTH_HEADER"
      });
    }

    const token = parts[1];

    const decoded =
      jwt.verify(
        token,
        JWT_SECRET,
        {
          issuer: "worthapp",
          audience: "worthapp-api"
        }
      );

    const result = await pool.query(
      `
      SELECT
        u.id,
        u.email,
        u.display_name,
        u.status,
        u.email_verified,
        u.created_at,
        u.last_login_at,
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
      [decoded.sub]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "User account not found.",
        code: "AUTH_USER_NOT_FOUND"
      });
    }

    return res.status(200).json({
      success: true,
      user: result.rows[0]
    });
  } catch (error) {
    if (
      error.name === "JsonWebTokenError" ||
      error.name === "TokenExpiredError"
    ) {
      return res.status(401).json({
        success: false,
        error: "Invalid or expired access token.",
        code: "AUTH_INVALID_ACCESS_TOKEN"
      });
    }

    console.error(
      "Worthapp current user error:",
      error
    );

    return res.status(500).json({
      success: false,
      error: "Unable to retrieve user account.",
      code: "AUTH_ME_ERROR"
    });
  }
});

/**
 * =========================================================
 * LOGOUT
 * =========================================================
 */

router.post("/logout", async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      refreshToken,
      sessionToken
    } = req.body;

    if (!refreshToken && !sessionToken) {
      return res.status(400).json({
        success: false,
        error:
          "Refresh token or session token is required.",
        code: "AUTH_LOGOUT_TOKEN_REQUIRED"
      });
    }

    await client.query("BEGIN");

    let userId = null;

    /**
     * -------------------------------------------------------
     * REVOKE REFRESH TOKEN
     * -------------------------------------------------------
     */

    if (refreshToken) {
      const refreshHash =
        hashToken(refreshToken);

      const refreshResult =
        await client.query(
          `
          UPDATE refresh_tokens
          SET revoked_at = NOW()
          WHERE token_hash = $1
            AND revoked_at IS NULL
          RETURNING user_id
          `,
          [refreshHash]
        );

      if (
        refreshResult.rows.length > 0
      ) {
        userId =
          refreshResult.rows[0].user_id;
      }
    }

    /**
     * -------------------------------------------------------
     * REVOKE SESSION
     * -------------------------------------------------------
     */

    if (sessionToken) {
      const sessionHash =
        hashToken(sessionToken);

      const sessionResult =
        await client.query(
          `
          UPDATE user_sessions
          SET revoked_at = NOW()
          WHERE session_token_hash = $1
            AND revoked_at IS NULL
          RETURNING user_id
          `,
          [sessionHash]
        );

      if (
        sessionResult.rows.length > 0
      ) {
        userId =
          userId ||
          sessionResult.rows[0].user_id;
      }
    }

    /**
     * -------------------------------------------------------
     * AUDIT LOG
     * -------------------------------------------------------
     */

    if (userId) {
      await client.query(
        `
        INSERT INTO audit_logs (
          user_id,
          action,
          resource_type,
          resource_id
        )
        VALUES (
          $1,
          'user.logout',
          'user',
          $1
        )
        `,
        [userId]
      );
    }

    await client.query("COMMIT");

    return res.status(200).json({
      success: true,
      message: "Logout completed successfully."
    });
  } catch (error) {
    await client.query("ROLLBACK");

    console.error(
      "Worthapp logout error:",
      error
    );

    return res.status(500).json({
      success: false,
      error: "Unable to logout.",
      code: "AUTH_LOGOUT_ERROR"
    });
  } finally {
    client.release();
  }
});

/**
 * =========================================================
 * EXPORT ROUTER
 * =========================================================
 */

module.exports = router;
