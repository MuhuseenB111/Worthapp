const AUTHORIZATION_HEADER = "authorization";
const BEARER_PREFIX = "Bearer ";

function getAuthorizationHeader(request) {
  return request.headers?.[AUTHORIZATION_HEADER] || null;
}

function extractBearerToken(request) {
  const authorization = getAuthorizationHeader(request);

  if (!authorization) {
    return null;
  }

  if (!authorization.startsWith(BEARER_PREFIX)) {
    return null;
  }

  const token = authorization.slice(BEARER_PREFIX.length).trim();

  if (!token) {
    return null;
  }

  return token;
}

function requireAuthentication(request, response, next) {
  if (!request.authenticatedUser) {
    response.writeHead(401, {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff"
    });

    response.end(
      JSON.stringify({
        success: false,
        error: "Authentication required."
      })
    );

    return;
  }

  next();
}

function attachAuthenticatedUser(request, user) {
  if (!user || typeof user !== "object") {
    throw new TypeError(
      "An authenticated user object is required."
    );
  }

  request.authenticatedUser = Object.freeze({
    ...user
  });
}

function isAuthenticated(request) {
  return Boolean(request.authenticatedUser);
}

export {
  getAuthorizationHeader,
  extractBearerToken,
  requireAuthentication,
  attachAuthenticatedUser,
  isAuthenticated
};
