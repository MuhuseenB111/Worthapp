const MAX_LOG_ENTRIES = 1000;

const SENSITIVE_KEYS = new Set([
  "password",
  "passwordHash",
  "token",
  "accessToken",
  "refreshToken",
  "authorization",
  "apiKey",
  "secret",
  "encryptionKey",
  "privateKey",
  "otp",
  "code"
]);

const auditEntries = [];

function sanitizeMetadata(metadata) {
  if (
    metadata === null ||
    metadata === undefined
  ) {
    return {};
  }

  if (
    typeof metadata !== "object" ||
    Array.isArray(metadata)
  ) {
    return {};
  }

  const sanitized = {};

  for (const [key, value] of Object.entries(
    metadata
  )) {
    if (
      SENSITIVE_KEYS.has(
        key.toLowerCase()
      )
    ) {
      continue;
    }

    if (
      typeof value === "string" &&
      value.length > 500
    ) {
      sanitized[key] =
        value.slice(0, 500);
      continue;
    }

    if (
      typeof value === "string" ||
      typeof value === "number" ||
      typeof value === "boolean" ||
      value === null
    ) {
      sanitized[key] = value;
    }
  }

  return sanitized;
}

function createAuditEntry({
  event,
  userId = null,
  requestId = null,
  ipAddress = null,
  metadata = {}
} = {}) {
  if (
    typeof event !== "string" ||
    !event.trim()
  ) {
    throw new TypeError(
      "Audit event must be a non-empty string."
    );
  }

  return {
    id: cryptoRandomId(),
    timestamp:
      new Date().toISOString(),
    event: event.trim(),
    userId:
      typeof userId === "string"
        ? userId
        : null,
    requestId:
      typeof requestId === "string"
        ? requestId
        : null,
    ipAddress:
      typeof ipAddress === "string"
        ? ipAddress
        : null,
    metadata:
      sanitizeMetadata(metadata)
  };
}

function cryptoRandomId() {
  const timestamp =
    Date.now().toString(36);

  const randomPart =
    Math.random()
      .toString(36)
      .slice(2, 12);

  return `audit_${timestamp}_${randomPart}`;
}

function recordAuditEvent(details) {
  const entry =
    createAuditEntry(details);

  auditEntries.push(entry);

  if (
    auditEntries.length >
    MAX_LOG_ENTRIES
  ) {
    auditEntries.shift();
  }

  return entry;
}

function getRecentAuditEvents(
  limit = 100
) {
  if (
    !Number.isInteger(limit) ||
    limit <= 0
  ) {
    throw new TypeError(
      "Audit log limit must be a positive integer."
    );
  }

  const safeLimit = Math.min(
    limit,
    MAX_LOG_ENTRIES
  );

  return auditEntries
    .slice(-safeLimit)
    .reverse()
    .map((entry) => ({
      ...entry,
      metadata: {
        ...entry.metadata
      }
    }));
}

function clearAuditEvents() {
  auditEntries.length = 0;
}

function getAuditLogStats() {
  return {
    entries: auditEntries.length,
    maximumEntries:
      MAX_LOG_ENTRIES
  };
}

export {
  recordAuditEvent,
  getRecentAuditEvents,
  clearAuditEvents,
  getAuditLogStats,
  sanitizeMetadata
};
