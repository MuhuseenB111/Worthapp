const DEFAULT_WINDOW_MS = 60 * 1000;
const DEFAULT_MAX_REQUESTS = 60;

const MAX_TRACKED_CLIENTS = 10_000;

const clients = new Map();

function getClientKey(request) {
  const forwardedFor = request.headers?.["x-forwarded-for"];

  if (typeof forwardedFor === "string" && forwardedFor.trim()) {
    return forwardedFor
      .split(",")[0]
      .trim();
  }

  return request.socket?.remoteAddress || "unknown";
}

function removeExpiredEntries(now, windowMs) {
  for (const [key, entry] of clients) {
    if (now - entry.windowStart >= windowMs) {
      clients.delete(key);
    }
  }
}

function rateLimit(
  request,
  response,
  next,
  {
    windowMs = DEFAULT_WINDOW_MS,
    maxRequests = DEFAULT_MAX_REQUESTS
  } = {}
) {
  if (
    !Number.isInteger(windowMs) ||
    windowMs <= 0
  ) {
    throw new TypeError(
      "windowMs must be a positive integer."
    );
  }

  if (
    !Number.isInteger(maxRequests) ||
    maxRequests <= 0
  ) {
    throw new TypeError(
      "maxRequests must be a positive integer."
    );
  }

  const now = Date.now();

  if (clients.size >= MAX_TRACKED_CLIENTS) {
    removeExpiredEntries(now, windowMs);
  }

  const clientKey = getClientKey(request);

  let entry = clients.get(clientKey);

  if (!entry || now - entry.windowStart >= windowMs) {
    entry = {
      windowStart: now,
      requestCount: 0
    };
  }

  entry.requestCount += 1;

  clients.set(clientKey, entry);

  const remainingRequests = Math.max(
    0,
    maxRequests - entry.requestCount
  );

  const retryAfterSeconds = Math.ceil(
    Math.max(
      0,
      windowMs - (now - entry.windowStart)
    ) / 1000
  );

  response.setHeader(
    "X-RateLimit-Limit",
    String(maxRequests)
  );

  response.setHeader(
    "X-RateLimit-Remaining",
    String(remainingRequests)
  );

  if (entry.requestCount > maxRequests) {
    response.setHeader(
      "Retry-After",
      String(retryAfterSeconds)
    );

    response.writeHead(429, {
      "Content-Type":
        "application/json; charset=utf-8",
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff"
    });

    response.end(
      JSON.stringify({
        success: false,
        error:
          "Too many requests. Please try again later."
      })
    );

    return;
  }

  next();
}

function clearRateLimiter() {
  clients.clear();
}

function getRateLimiterStats() {
  return {
    trackedClients: clients.size,
    maxTrackedClients: MAX_TRACKED_CLIENTS
  };
}

export {
  rateLimit,
  clearRateLimiter,
  getRateLimiterStats
};
