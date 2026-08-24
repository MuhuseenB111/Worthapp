"use strict";

/**
 * =========================================================
 * WORTHAPP
 * DATABASE CONNECTION
 *
 * PostgreSQL / Supabase PostgreSQL connection pool
 *
 * File:
 * database/connection.js
 *
 * Responsibilities:
 * - Create PostgreSQL connection pool
 * - Read DATABASE_URL securely from environment
 * - Support production SSL
 * - Execute database queries
 * - Test database connection
 * - Close database connections safely
 * =========================================================
 */

const { Pool } = require("pg");

/**
 * =========================================================
 * DATABASE CONFIGURATION
 * =========================================================
 */

const databaseUrl =
  process.env.DATABASE_URL;

/**
 * =========================================================
 * DATABASE URL VALIDATION
 * =========================================================
 *
 * DATABASE_URL should be provided through:
 *
 * .env
 *
 * Example:
 *
 * DATABASE_URL=postgresql://...
 *
 * IMPORTANT:
 * Never place the real database password directly
 * inside this JavaScript file.
 */

if (!databaseUrl) {
  console.warn(
    "Worthapp warning: DATABASE_URL is not configured."
  );
}

/**
 * =========================================================
 * POOL CONFIGURATION
 * =========================================================
 */

const poolConfig = {
  connectionString:
    databaseUrl,

  max: 10,

  idleTimeoutMillis:
    30000,

  connectionTimeoutMillis:
    10000
};

/**
 * =========================================================
 * PRODUCTION SSL
 * =========================================================
 *
 * Supabase PostgreSQL connections commonly require
 * SSL depending on the connection endpoint.
 */

if (
  process.env.NODE_ENV ===
  "production"
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

const pool =
  new Pool(poolConfig);

/**
 * =========================================================
 * DATABASE CONNECTION EVENT
 * ========================================================= */

pool.on(
  "connect",
  () => {
    console.log(
      "Worthapp database connection established."
    );
  }
);

/**
 * =========================================================
 * DATABASE ERROR EVENT
 * ========================================================= */

pool.on(
  "error",
  (error) => {
    console.error(
      "Worthapp database pool error:",
      error
    );
  }
);

/**
 * =========================================================
 * DATABASE QUERY
 * =========================================================
 *
 * Central database query function.
 */

async function query(
  text,
  params = []
) {
  return pool.query(
    text,
    params
  );
}

/**
 * =========================================================
 * DATABASE CONNECTION TEST
 * =========================================================
 *
 * Used by:
 *
 * GET /health
 *
 * Returns the current database time
 * when the connection is working.
 */

async function testDatabaseConnection() {
  const result =
    await pool.query(
      "SELECT NOW() AS current_time"
    );

  return {
    connected: true,

    currentTime:
      result.rows[0]
        .current_time
  };
}

/**
 * =========================================================
 * CLOSE DATABASE CONNECTION
 * =========================================================
 *
 * Used during graceful server shutdown.
 */

async function closeDatabaseConnection() {
  try {
    await pool.end();

    console.log(
      "Worthapp database connection pool closed."
    );

  } catch (error) {
    console.error(
      "Worthapp database shutdown error:",
      error
    );

    throw error;
  }
}

/**
 * =========================================================
 * GET DATABASE POOL
 * =========================================================
 *
 * Provides controlled access to the pool when
 * another backend module needs it.
 */

function getDatabasePool() {
  return pool;
}

/**
 * =========================================================
 * MODULE EXPORTS
 * =========================================================
 */

module.exports = {
  pool,

  query,

  testDatabaseConnection,

  closeDatabaseConnection,

  getDatabasePool
};
