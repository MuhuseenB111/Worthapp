const DEFAULT_MAX_BYTES = 1 * 1024 * 1024;

function getMaxRequestSize() {
  const configuredLimit =
    Number.parseInt(
      process.env.WORTHAPP_MAX_REQUEST_BYTES,
      10
    );

  if (
    Number.isSafeInteger(configuredLimit) &&
    configuredLimit > 0
  ) {
    return configuredLimit;
  }

  return DEFAULT_MAX_BYTES;
}

function requestSize(request, response, next) {
  const contentLength =
    request.headers["content-length"];

  if (!contentLength) {
    next();
    return;
  }

  const requestSizeBytes =
    Number.parseInt(contentLength, 10);

  if (
    !Number.isSafeInteger(requestSizeBytes) ||
    requestSizeBytes < 0
  ) {
    response.status(400).json({
      success: false,
      message: "Girman bayanan da aka aika bai dace ba."
    });

    return;
  }

  const maxBytes = getMaxRequestSize();

  if (requestSizeBytes > maxBytes) {
    response.status(413).json({
      success: false,
      message:
        "Bayanan da aka aika sun yi yawa. Da fatan a rage girman bayanan sannan a sake gwadawa."
    });

    return;
  }

  next();
}

export {
  requestSize,
  getMaxRequestSize
};
