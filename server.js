"use strict";

/**
 * =========================================================
 * WORTHAPP
 * GLOBAL DIGITAL PLATFORM
 *
 * MAIN SERVER
 *
 * This server connects Express with the central
 * Worthapp route registry.
 * =========================================================
 */

const express = require("express");

const app = express();

/**
 * =========================================================
 * CONFIGURATION
 * =========================================================
 */

const PORT = Number(process.env.PORT) || 3000;

const SERVER_NAME = "Worthapp";

const API_PREFIX = "/api/v1";

/**
 * =========================================================
 * SECURITY HEADERS
 * =========================================================
 */

app.disable("x-powered-by");

app.use((req, res, next) => {
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader("X-Frame-Options", "DENY");
  res.setHeader("Referrer-Policy", "no-referrer");
  res.setHeader(
    "Permissions-Policy",
    "camera=(), microphone=(), geolocation=()"
  );
  res.setHeader("Cache-Control", "no-store");

  next();
});

/**
 * =========================================================
 * BODY PARSING
 * =========================================================
 */

app.use(express.json({ limit: "1mb" }));

app.use(
  express.urlencoded({
    extended: true,
    limit: "1mb"
  })
);

/**
 * =========================================================
 * CENTRAL ROUTE REGISTRY
 * =========================================================
 */

const routes = require("./routes/routes");

app.use(API_PREFIX, routes);

/**
 * =========================================================
 * ROOT SERVER STATUS
 * =========================================================
 */

app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    application: SERVER_NAME,
    message: "Worthapp server is running.",
    status: "online",
    api: API_PREFIX
  });
});

/**
 * =========================================================
 * SERVER HEALTH
 * =========================================================
 */

app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    application: SERVER_NAME,
    status: "healthy",
    timestamp: new Date().toISOString()
  });
});

/**
 * =========================================================
 * 404 HANDLER
 * =========================================================
 */

app.use((req, res) => {
  res.status(404).json({
    success: false,
    application: SERVER_NAME,
    error: "Route not found.",
    path: req.originalUrl
  });
});

/**
 * =========================================================
 * GLOBAL ERROR HANDLER
 * =========================================================
 */

app.use((error, req, res, next) => {
  console.error("Worthapp API error:", error);

  res.status(error.status || 500).json({
    success: false,
    application: SERVER_NAME,
    error: "Internal server error."
  });
});

/**
 * =========================================================
 * START SERVER
 * =========================================================
 */

const server = app.listen(PORT, () => {
  console.log(
    `${SERVER_NAME} server is running on port ${PORT}`
  );

  console.log(
    `${SERVER_NAME} API is available at ${API_PREFIX}`
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
