function errorHandler(error, request, response, next) {
  const statusCode =
    Number.isInteger(error?.statusCode) &&
    error.statusCode >= 400 &&
    error.statusCode < 600
      ? error.statusCode
      : 500;

  const requestId =
    typeof request?.requestId === "string"
      ? request.requestId
      : null;

  const isProduction =
    process.env.NODE_ENV === "production";

  const publicMessage =
    statusCode >= 500
      ? "An samu matsala a tsarin Worthapp. Da fatan za a sake gwadawa daga baya."
      : (
          typeof error?.publicMessage === "string" &&
          error.publicMessage.trim().length > 0
            ? error.publicMessage
            : "An samu kuskure wajen aiwatar da bukatarka."
        );

  const errorResponse = {
    success: false,
    message: publicMessage,
    requestId
  };

  if (!isProduction && statusCode >= 500) {
    errorResponse.debug = {
      name: error?.name || "Error",
      message: error?.message || "Unknown error"
    };
  }

  if (!response.headersSent) {
    response.status(statusCode).json(errorResponse);
    return;
  }

  next(error);
}

function notFoundHandler(request, response) {
  const requestId =
    typeof request?.requestId === "string"
      ? request.requestId
      : null;

  response.status(404).json({
    success: false,
    message: "Ba a samu wannan hanyar sadarwa ba.",
    requestId
  });
}

export {
  errorHandler,
  notFoundHandler
};
