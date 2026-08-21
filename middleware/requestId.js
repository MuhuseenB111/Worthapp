import { randomUUID } from "node:crypto";

const REQUEST_ID_HEADER = "X-Request-ID";

function createRequestId() {
  return randomUUID();
}

function requestId(request, response, next) {
  const id = createRequestId();

  request.requestId = id;

  response.setHeader(
    REQUEST_ID_HEADER,
    id
  );

  next();
}

function getRequestId(request) {
  if (
    !request ||
    typeof request !== "object"
  ) {
    return null;
  }

  return (
    typeof request.requestId === "string"
      ? request.requestId
      : null
  );
}

export {
  requestId,
  createRequestId,
  getRequestId
};
