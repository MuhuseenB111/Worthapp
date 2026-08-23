"use strict";

/**
 * =========================================================
 * WORTHAPP
 * DATABASE CONNECTION
 *
 * PostgreSQL connection pool
 *
 * File: database/connection.js
 * =========================================================
 */

const { Pool } = require("pg");

/**
 * =========================================================
 * DATABASE CONFIGURATION
 * =========================================================
 */

const databaseUrl = process.env.DATABASE_URL;

const nodeEnvironment =
  process.env.NODE_ENV || "development";

/**
 * Fail fast when DATABASE_URL is missing.
 *
 * This prevents the application from running with
 * an invalid database configuration.
 */
if (
  !databaseUrl ||
  typeof databaseUrl !== "string"
) {
  throw new Error(
    "DATABASE_URL is not configured. Please configure the PostgreSQL database connection."
  );
}

/**
 * =========================================================
 * CONNECTION POOL CONFIGURATION
 * =========================================================
 */

const poolConfig = {
  connectionString: databaseUrl,

  max: 10,

  idleTimeoutMillis: 30000,

  connectionTimeoutMillis: 10000,

  allowExitOnIdle: false
};

/**
 * =========================================================
 * SSL CONFIGURATION
 * =========================================================
 *
 * Production databases commonly require SSL.
 *
 * For local development we leave SSL disabled unless
 * explicitly enabled through DATABASE_SSL.
 * =========================================================
 */

const databaseSsl =
  process.env.DATABASE_SSL === "true";

if (
  nodeEnvironment === "production" ||
  databaseSsl
) {
  poolConfig.ssl = {
    rejectUnauthorized: false
  };
}

/**
 * =========================================================
 * DATABASE POOL
 * =========================================================
 */

const pool = new Pool(poolConfig);

/**
 * =========================================================
 * DATABASE EVENTS
 * =========================================================
 */

pool.on("connect", () => {
  console.log(
    "Worthapp database connection established."
  );
});

pool.on("remove", () => {
  console.log(
    "Worthapp database connection removed from pool."
  );
});

pool.on("error", (error) => {
  console.error(
    "Worthapp database pool error:",
    error
  );
});

/**
 * =========================================================
 * DATABASE QUERY
 * =========================================================
 *
 * Central query function used by services.
 * =========================================================
 */

async function query(text, params = []) {
  if (
    typeof text !== "string" ||
    !text.trim()
  ) {
    throw new TypeError(
      "Database query must be a non-empty string."
    );
  }

  return pool.query(text, params);
}

/**
 * =========================================================
 * DATABASE CONNECTION TEST
 * =========================================================
 */

async function testDatabaseConnection() {
  const result = await pool.query(
    "SELECT NOW() AS current_time"
  );

  return {
    connected: true,
    currentTime:
      result.rows[0].current_time
  };
}

/**
 * =========================================================
 * DATABASE HEALTH
 * =========================================================
 */

async function getDatabaseHealth() {
  try {
    await pool.query("SELECT 1");

    return {
      status: "healthy",
      database: "postgresql"
    };
  } catch (error) {
    console.error(
      "Worthapp database health check failed:",
      error
    );

    return {
      status: "unhealthy",
      database: "postgresql"
    };
  }
}

/**
 * =========================================================
 * CLOSE DATABASE
 * =========================================================
 *
 * Used during graceful server shutdown.
 * =========================================================
 */

async function closeDatabase() {
  await pool.end();

  console.log(
    "Worthapp database pool closed."
  );
}

/**
 * =========================================================
 * EXPORTS
 * =========================================================
 */

module.exports = {
  pool,
  query,
  testDatabaseConnection,
  getDatabaseHealth,
  closeDatabase
};
