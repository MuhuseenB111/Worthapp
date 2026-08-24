"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * MAIN SERVER
 *
 * File: server.js
 *
 * Responsibilities:
 * - Load environment variables
 * - Start Express server
 * - Connect central route registry
 * - Monitor PostgreSQL / Supabase database
 * - Apply security headers
 * - Handle 404 responses
 * - Handle global errors
 * - Graceful shutdown
 * =========================================================
 */

/**
 * =========================================================
 * ENVIRONMENT CONFIGURATION
 * =========================================================
 *
 * IMPORTANT:
 * dotenv must load BEFORE database/connection.js
 * so DATABASE_URL and other environment variables
 * are available when the database pool is created.
 */

require("dotenv").config();

/**
 * =========================================================
 * DEPENDENCIES
 * =========================================================
 */

const express = require("express");

const {
  testDatabaseConnection,
  closeDatabaseConnection
} = require("./database/connection");

/**
 * =========================================================
 * EXPRESS APPLICATION
 * =========================================================
 */

const app = express();

/**
 * =========================================================
 * APPLICATION CONFIGURATION
 * =========================================================
 */

const PORT =
  Number(process.env.PORT) || 3000;

const SERVER_NAME =
  "Worthapp";

const API_PREFIX =
  "/api/v1";

/**
 * =========================================================
 * BASIC SECURITY CONFIGURATION
 * =========================================================
 */

app.disable("x-powered-by");

/**
 * =========================================================
 * SECURITY HEADERS
 * =========================================================
 */

app.use((req, res, next) => {
  res.setHeader(
    "X-Content-Type-Options",
    "nosniff"
  );

  res.setHeader(
    "X-Frame-Options",
    "DENY"
  );

  res.setHeader(
    "Referrer-Policy",
    "no-referrer"
  );

  res.setHeader(
    "Permissions-Policy",
    "camera=(), microphone=(), geolocation=()"
  );

  res.setHeader(
    "Cache-Control",
    "no-store"
  );

  res.setHeader(
    "Cross-Origin-Opener-Policy",
    "same-origin"
  );

  res.setHeader(
    "Cross-Origin-Resource-Policy",
    "same-origin"
  );

  next();
});

/**
 * =========================================================
 * REQUEST BODY PARSING
 * =========================================================
 */

app.use(
  express.json({
    limit: "1mb"
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: "1mb"
  })
);

/**
 * =========================================================
 * REQUEST LOGGING
 * =========================================================
 *
 * Basic development logging.
 *
 * We intentionally do not log:
 * - passwords
 * - authorization tokens
 * - request bodies
 * - sensitive personal information
 */

app.use((req, res, next) => {
  const startedAt =
    Date.now();

  res.on(
    "finish",
    () => {
      const duration =
        Date.now() - startedAt;

      console.log(
        `[Worthapp] ${req.method} ${req.originalUrl} ${res.statusCode} ${duration}ms`
      );
    }
  );

  next();
});

/**
 * =========================================================
 * CENTRAL ROUTE REGISTRY
 * =========================================================
 */

const routes =
  require("./routes/routes");

app.use(
  API_PREFIX,
  routes
);

/**
 * =========================================================
 * ROOT SERVER STATUS
 * =========================================================
 *
 * GET /
 */

app.get(
  "/",
  (req, res) => {
    return res.status(200).json({
      success: true,

      application:
        SERVER_NAME,

      message:
        "Worthapp server is running.",

      status:
        "online",

      api:
        API_PREFIX,

      timestamp:
        new Date().toISOString()
    });
  }
);

/**
 * =========================================================
 * SERVER + DATABASE HEALTH
 * =========================================================
 *
 * GET /health
 *
 * This endpoint checks:
 * - Express server
 * - PostgreSQL / Supabase database
 */

app.get(
  "/health",
  async (req, res) => {
    try {
      const database =
        await testDatabaseConnection();

      return res.status(200).json({
        success: true,

        application:
          SERVER_NAME,

        status:
          "healthy",

        services: {
          server:
            "healthy",

          database:
            "connected"
        },

        database: {
          connected:
            database.connected,

          currentTime:
            database.currentTime
        },

        timestamp:
          new Date().toISOString()
      });

    } catch (error) {
      console.error(
        "Worthapp database health error:",
        error
      );

      return res.status(503).json({
        success: false,

        application:
          SERVER_NAME,

        status:
          "unhealthy",

        services: {
          server:
            "healthy",

          database:
            "disconnected"
        },

        error:
          "Database connection is unavailable.",

        timestamp:
          new Date().toISOString()
      });
    }
  }
);

/**
 * =========================================================
 * 404 HANDLER
 * ========================================================= */

app.use(
  (req, res) => {
    return res.status(404).json({
      success: false,

      application:
        SERVER_NAME,

      error:
        "Route not found.",

      path:
        req.originalUrl,

      timestamp:
        new Date().toISOString()
    });
  }
);

/**
 * =========================================================
 * GLOBAL ERROR HANDLER
 * ========================================================= */

app.use(
  (error, req, res, next) => {
    console.error(
      "Worthapp API error:",
      error
    );

    const statusCode =
      Number(error.statusCode) ||
      Number(error.status) ||
      500;

    const safeStatusCode =
      statusCode >= 400 &&
      statusCode < 600
        ? statusCode
        : 500;

    return res
      .status(safeStatusCode)
      .json({
        success: false,

        application:
          SERVER_NAME,

        error:
          safeStatusCode === 500
            ? "Internal server error."
            : error.message ||
              "Request failed.",

        timestamp:
          new Date().toISOString()
      });
  }
);

/**
 * =========================================================
 * SERVER STARTUP
 * ========================================================= */

const server =
  app.listen(
    PORT,
    () => {
      console.log(
        "=========================================="
      );

      console.log(
        `${SERVER_NAME} server is running on port ${PORT}`
      );

      console.log(
        `${SERVER_NAME} API: ${API_PREFIX}`
      );

      console.log(
        `${SERVER_NAME} health: /health`
      );

      console.log(
        "=========================================="
      );
    }
  );

/**
 * =========================================================
 * SERVER ERROR
 * ========================================================= */

server.on(
  "error",
  (error) => {
    console.error(
      "Worthapp server error:",
      error
    );
  }
);

/**
 * =========================================================
 * GRACEFUL SHUTDOWN
 * =========================================================
 */

let isShuttingDown =
  false;

async function shutdown(signal) {
  if (isShuttingDown) {
    return;
  }

  isShuttingDown =
    true;

  console.log(
    `${signal} received. Shutting down ${SERVER_NAME} server...`
  );

  server.close(
    async () => {
      try {
        if (
          typeof closeDatabaseConnection ===
          "function"
        ) {
          await closeDatabaseConnection();
        }

        console.log(
          `${SERVER_NAME} server stopped safely.`
        );

        process.exit(0);

      } catch (error) {
        console.error(
          "Worthapp shutdown error:",
          error
        );

        process.exit(1);
      }
    }
  );
}

/**
 * =========================================================
 * PROCESS SIGNALS
 * ========================================================= */

process.on(
  "SIGTERM",
  () => {
    shutdown("SIGTERM");
  }
);

process.on(
  "SIGINT",
  () => {
    shutdown("SIGINT");
  }
);

/**
 * =========================================================
 * UNHANDLED PROMISE REJECTION
 * ========================================================= */

process.on(
  "unhandledRejection",
  (reason) => {
    console.error(
      "Worthapp unhandled promise rejection:",
      reason
    );
  }
);

/**
 * =========================================================
 * UNCAUGHT EXCEPTION
 * ========================================================= */

process.on(
  "uncaughtException",
  (error) => {
    console.error(
      "Worthapp uncaught exception:",
      error
    );

    shutdown(
      "uncaughtException"
    );
  }
);

/**
 * =========================================================
 * EXPORT APPLICATION
 * =========================================================
 *
 * Exporting app makes testing easier later.
 */

module.exports = {
  app,
  server
};
