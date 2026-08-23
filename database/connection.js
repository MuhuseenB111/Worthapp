"use strict";

/**
 * =========================================================
 * WORTHAPP
 * DATABASE CONNECTION
 *
 * PostgreSQL connection pool
 * =========================================================
 */

const { Pool } = require("pg");

/**
 * =========================================================
 * DATABASE CONFIGURATION
 * =========================================================
 */

const databaseUrl = process.env.DATABASE_URL;

const poolConfig = {
  connectionString: databaseUrl,

  max: 10,

  idleTimeoutMillis: 30000,

  connectionTimeoutMillis: 10000
};

/**
 * Enable SSL in production.
 */
if (process.env.NODE_ENV === "production") {
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
  console.log("Worthapp database connection established.");
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
 */

async function query(text, params) {
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
    currentTime: result.rows[0].current_time
  };
}

/**
 * =========================================================
 * EXPORTS
 * =========================================================
 */

module.exports = {
  pool,
  query,
  testDatabaseConnection
};
