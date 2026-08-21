function secureHeaders(request, response, next) {
  response.setHeader(
    "X-Content-Type-Options",
    "nosniff"
  );

  response.setHeader(
    "X-Frame-Options",
    "DENY"
  );

  response.setHeader(
    "Referrer-Policy",
    "strict-origin-when-cross-origin"
  );

  response.setHeader(
    "Permissions-Policy",
    [
      "camera=(self)",
      "microphone=(self)",
      "geolocation=(self)",
      "payment=(self)"
    ].join(", ")
  );

  response.setHeader(
    "Cross-Origin-Opener-Policy",
    "same-origin"
  );

  response.setHeader(
    "Cross-Origin-Resource-Policy",
    "same-origin"
  );

  response.setHeader(
    "X-Permitted-Cross-Domain-Policies",
    "none"
  );

  response.setHeader(
    "X-DNS-Prefetch-Control",
    "off"
  );

  if (
    process.env.NODE_ENV === "production" &&
    request.secure
  ) {
    response.setHeader(
      "Strict-Transport-Security",
      "max-age=31536000; includeSubDomains"
    );
  }

  next();
}

export default secureHeaders;
