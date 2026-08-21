"use strict";

const express = require("express");
const path = require("node:path");
const { randomUUID } = require("node:crypto");

const app = express();

const PORT = Number(process.env.PORT) || 3000;
const SERVER_NAME = "Worthapp";
const NODE_ENV = process.env.NODE_ENV || "development";

/*
|--------------------------------------------------------------------------
| BASIC SECURITY
|--------------------------------------------------------------------------
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

/*
|--------------------------------------------------------------------------
| REQUEST ID
|--------------------------------------------------------------------------
*/

app.use((req, res, next) => {
  const requestId = req.headers["x-request-id"] || randomUUID();

  req.requestId = requestId;
  res.setHeader("X-Request-ID", requestId);

  next();
});

/*
|--------------------------------------------------------------------------
| BODY PARSERS
|--------------------------------------------------------------------------
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

/*
|--------------------------------------------------------------------------
| ROOT
|--------------------------------------------------------------------------
*/

app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    application: SERVER_NAME,
    message: "Worthapp server is running.",
    status: "online",
    environment: NODE_ENV,
    requestId: req.requestId
  });
});

/*
|--------------------------------------------------------------------------
| HEALTH CHECK
|--------------------------------------------------------------------------
*/

app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    application: SERVER_NAME,
    service: "Worthapp API",
    status: "healthy",
    timestamp: new Date().toISOString(),
    requestId: req.requestId
  });
});

/*
|--------------------------------------------------------------------------
| API INFORMATION
|--------------------------------------------------------------------------
*/

app.get("/api", (req, res) => {
  res.status(200).json({
    success: true,
    application: SERVER_NAME,
    apiVersion: "v1",
    status: "online",
    endpoints: {
      health: "/health",
      api: "/api",
      routes: "/api/v1"
    },
    timestamp: new Date().toISOString()
  });
});

/*
|--------------------------------------------------------------------------
| CENTRAL ROUTES
|--------------------------------------------------------------------------
|
| We intentionally load the central routes file separately.
| This prevents us from automatically mounting every route file
| before their individual contracts have been verified.
|
*/

try {
  const routes = require("./routes/routes");

  if (typeof routes === "function") {
    app.use("/api/v1", routes);
  } else {
    console.warn(
      "Worthapp warning: ./routes/routes.js did not export an Express router."
    );
  }
} catch (error) {
  console.warn(
    "Worthapp warning: central routes could not be loaded yet."
  );

  console.warn(error.message);
}

/*
|--------------------------------------------------------------------------
| 404 HANDLER
|--------------------------------------------------------------------------
*/

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: "Route not found.",
    path: req.originalUrl,
    method: req.method,
    requestId: req.requestId
  });
});

/*
|--------------------------------------------------------------------------
| GLOBAL ERROR HANDLER
|--------------------------------------------------------------------------
*/

app.use((error, req, res, next) => {
  console.error("Worthapp application error:", error);

  if (res.headersSent) {
    return next(error);
  }

  const statusCode =
    Number(error.statusCode) ||
    Number(error.status) ||
    500;

  res.status(statusCode).json({
    success: false,
    error:
      NODE_ENV === "production"
        ? "Internal server error."
        : error.message || "Internal server error.",
    requestId: req.requestId
  });
});

/*
|--------------------------------------------------------------------------
| START SERVER
|--------------------------------------------------------------------------
*/

const server = app.listen(PORT, () => {
  console.log("======================================");
  console.log(`${SERVER_NAME} server started successfully.`);
  console.log(`Environment: ${NODE_ENV}`);
  console.log(`Port: ${PORT}`);
  console.log(`Health: http://localhost:${PORT}/health`);
  console.log(`API: http://localhost:${PORT}/api`);
  console.log("======================================");
});

/*
|--------------------------------------------------------------------------
| SERVER ERROR
|--------------------------------------------------------------------------
*/

server.on("error", (error) => {
  console.error(`${SERVER_NAME} server error:`, error);

  if (error.code === "EADDRINUSE") {
    console.error(`Port ${PORT} is already in use.`);
  }
});

/*
|--------------------------------------------------------------------------
| GRACEFUL SHUTDOWN
|--------------------------------------------------------------------------
*/

function shutdown(signal) {
  console.log(`${signal} received.`);
  console.log("Shutting down Worthapp safely...");

  server.close((error) => {
    if (error) {
      console.error("Shutdown error:", error);
      process.exit(1);
    }

    console.log("Worthapp server stopped safely.");
    process.exit(0);
  });
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));

/*
|--------------------------------------------------------------------------
| UNEXPECTED ERRORS
|--------------------------------------------------------------------------
*/

process.on("uncaughtException", (error) => {
  console.error("Worthapp uncaught exception:", error);
});

process.on("unhandledRejection", (reason) => {
  console.error("Worthapp unhandled rejection:", reason);
});

module.exports = app;
