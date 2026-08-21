const DEFAULT_ALLOWED_METHODS = [
  "GET",
  "POST",
  "PUT",
  "PATCH",
  "DELETE",
  "OPTIONS"
];

const DEFAULT_ALLOWED_HEADERS = [
  "Content-Type",
  "Authorization",
  "X-Request-ID"
];

function getAllowedOrigins() {
  const configuredOrigins =
    process.env.WORTHAPP_ALLOWED_ORIGINS;

  if (
    typeof configuredOrigins !== "string" ||
    configuredOrigins.trim() === ""
  ) {
    return [];
  }

  return configuredOrigins
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}

function isAllowedOrigin(origin) {
  if (!origin) {
    return false;
  }

  const allowedOrigins = getAllowedOrigins();

  return allowedOrigins.includes(origin);
}

function cors(request, response, next) {
  const origin = request.headers.origin;

  if (origin && isAllowedOrigin(origin)) {
    response.setHeader(
      "Access-Control-Allow-Origin",
      origin
    );

    response.setHeader(
      "Vary",
      "Origin"
    );

    response.setHeader(
      "Access-Control-Allow-Credentials",
      "true"
    );

    response.setHeader(
      "Access-Control-Allow-Methods",
      DEFAULT_ALLOWED_METHODS.join(", ")
    );

    response.setHeader(
      "Access-Control-Allow-Headers",
      DEFAULT_ALLOWED_HEADERS.join(", ")
    );

    response.setHeader(
      "Access-Control-Max-Age",
      "600"
    );
  }

  if (request.method === "OPTIONS") {
    if (!origin || !isAllowedOrigin(origin)) {
      response.status(403).json({
        success: false,
        message: "Ba a yarda da wannan tushen sadarwa ba."
      });

      return;
    }

    response.status(204).end();
    return;
  }

  next();
}

export {
  cors,
  getAllowedOrigins,
  isAllowedOrigin
};
