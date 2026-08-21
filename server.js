import http from "node:http";

const PORT = Number(process.env.PORT) || 3000;

const SERVER_NAME = "Worthapp";

const securityHeaders = {
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
  "Referrer-Policy": "no-referrer",
  "Permissions-Policy": "camera=(), microphone=(), geolocation=()",
  "Cache-Control": "no-store"
};

function sendJson(response, statusCode, data) {
  response.writeHead(statusCode, {
    ...securityHeaders,
    "Content-Type": "application/json; charset=utf-8"
  });

  response.end(JSON.stringify(data));
}

function requestHandler(request, response) {
  const method = request.method || "GET";
  const url = new URL(
    request.url || "/",
    `http://${request.headers.host || "localhost"}`
  );

  if (method === "GET" && url.pathname === "/") {
    return sendJson(response, 200, {
      success: true,
      application: SERVER_NAME,
      message: "Worthapp server is running.",
      status: "online"
    });
  }

  if (method === "GET" && url.pathname === "/health") {
    return sendJson(response, 200, {
      success: true,
      application: SERVER_NAME,
      status: "healthy"
    });
  }

  return sendJson(response, 404, {
    success: false,
    error: "Route not found."
  });
}

const server = http.createServer(requestHandler);

server.on("error", (error) => {
  console.error("Worthapp server error:", error);
});

server.listen(PORT, () => {
  console.log(`${SERVER_NAME} server is running on port ${PORT}`);
});

function shutdown(signal) {
  console.log(`${signal} received. Shutting down Worthapp server...`);

  server.close(() => {
    console.log("Worthapp server stopped safely.");
    process.exit(0);
  });
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));
