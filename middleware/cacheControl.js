function cacheControl(request, response, next) {
  response.setHeader(
    "Cache-Control",
    "no-store, no-cache, must-revalidate, private"
  );

  response.setHeader(
    "Pragma",
    "no-cache"
  );

  response.setHeader(
    "Expires",
    "0"
  );

  next();
}

export default cacheControl;
