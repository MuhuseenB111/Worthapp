"use strict";

/**
 * =========================================================
 * WORTHAPP
 * Global Digital Platform
 *
 * Main Express Server
 *
 * This file starts the Worthapp API server
 * and registers the central route registry.
 * =========================================================
 */

const express = require("express");

const app = express();

const PORT = Number(process.env.PORT) || 3000;

const SERVER_NAME = "Worthapp";

/**
 * =========================================================
 * SECURITY HEADERS
 * =========================================================
 */

const securityHeaders = {
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
  "Referrer-Policy": "no-referrer",
  "Permissions-Policy": "camera=(), microphone=(), geolocation=()",
  "Cache-Control": "no-store"
};

/**
 * Apply security headers to every response.
 */
app.use((req, res, next) => {
  Object.entries(securityHeaders).forEach(([name, value]) => {
    res.setHeader(name, value);
  });

  next();
});

/**
 * =========================================================
 * REQUEST PARSING
 * =========================================================
 */

/**
 * Parse JSON request bodies.
 *
 * Required by routes such as:
 *
 * POST /wallet/deposit
 * POST /wallet/withdraw
 * POST /wallet/transfer
 */
app.use(
  express.json({
    limit: "1mb"
  })
);

/**
 * Parse URL-encoded request bodies.
 */
app.use(
  express.urlencoded({
    extended: true,
    limit: "1mb"
  })
);

/**
 * =========================================================
 * BASIC SERVER INFORMATION
 * =========================================================
 */

app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    application: SERVER_NAME,
    message: "Worthapp server is running.",
    status: "online",
    version: "1.0.0",
    environment: process.env.NODE_ENV || "development",
    timestamp: new Date().toISOString()
  });
});

/**
 * =========================================================
 * CENTRAL ROUTE REGISTRY
 * =========================================================
 *
 * All Worthapp API route modules are registered
 * through routes/routes.js.
 */

const routes = require("./routes/routes");

app.use("/api/v1", routes);

/**
 * =========================================================
 * GLOBAL 404 HANDLER
 * =========================================================
 */

app.use((req, res) => {
  res.status(404).json({
    success: false,
    application: SERVER_NAME,
    error: "Route not found.",
    path: req.originalUrl,
    method: req.method
  });
});

/**
 * =========================================================
 * GLOBAL ERROR HANDLER
 * =========================================================
 */

app.use((error, req, res, next) => {
  console.error("Worthapp API error:", error);

  if (res.headersSent) {
    return next(error);
  }

  res.status(error.status || 500).json({
    success: false,
    application: SERVER_NAME,
    error: "Internal server error."
  });
});

/**
 * =========================================================
 * SERVER
 * =========================================================
 */

const server = app.listen(PORT, () => {
  console.log(
    `${SERVER_NAME} server is running on port ${PORT}`
  );

  console.log(
    `${SERVER_NAME} API: http://localhost:${PORT}/api/v1`
  );
});

/**
 * =========================================================
 * SERVER ERROR
 * =========================================================
 */

server.on("error", (error) => {
  console.error("Worthapp server error:", error);
});

/**
 * =========================================================
 * GRACEFUL SHUTDOWN
 * =========================================================
 */

function shutdown(signal) {
  console.log(
    `${signal} received. Shutting down ${SERVER_NAME} server...`
  );

  server.close(() => {
    console.log(
      `${SERVER_NAME} server stopped safely.`
    );

    process.exit(0);
  });
}

process.on("SIGTERM", () => {
  shutdown("SIGTERM");
});

process.on("SIGINT", () => {
  shutdown("SIGINT");
});

/**
 * =========================================================
 * EXPORT
 * =========================================================
 *
 * Exporting the app makes testing easier in the future.
 */

module.exports = app;
