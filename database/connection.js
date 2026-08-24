"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * DATABASE CONNECTION
 *
 * PostgreSQL connection pool
 *
 * File:
 * database/connection.js
 *
 * Responsibilities:
 * - Load environment configuration
 * - Create PostgreSQL connection pool
 * - Execute database queries
 * - Test database connection
 * - Close database connection safely
 * =========================================================
 */

/**
 * =========================================================
 * ENVIRONMENT CONFIGURATION
 * =========================================================
 */

require("dotenv").config();

/**
 * =========================================================
 * POSTGRESQL
 * =========================================================
 */

const {
  Pool
} = require("pg");

/**
 * =========================================================
 * DATABASE CONFIGURATION
 * =========================================================
 */

const databaseUrl =
  process.env.DATABASE_URL;

/**
 * ---------------------------------------------------------
 * DATABASE URL VALIDATION
 * ---------------------------------------------------------
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
 * DATABASE EVENTS
 * =========================================================
 */

pool.on(
  "connect",
  () => {
    console.log(
      "Worthapp database connection established."
    );
  }
);

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
 */

async function query(
  text,
  params
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
 * Used by server.js during graceful shutdown.
 */

async function closeDatabaseConnection() {
  await pool.end();

  console.log(
    "Worthapp database connection closed."
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

  closeDatabaseConnection
};
