const REQUIRED_SECRET_NAMES = [
  "WORTHAPP_ENCRYPTION_KEY",
  "WORTHAPP_JWT_SECRET"
];

function getSecret(name) {
  if (
    typeof name !== "string" ||
    !name.trim()
  ) {
    throw new TypeError(
      "Secret name must be a non-empty string."
    );
  }

  const value = process.env[name];

  if (
    typeof value !== "string" ||
    value.length === 0
  ) {
    throw new Error(
      `Required secret is missing: ${name}`
    );
  }

  return value;
}

function hasSecret(name) {
  if (
    typeof name !== "string" ||
    !name.trim()
  ) {
    return false;
  }

  const value = process.env[name];

  return (
    typeof value === "string" &&
    value.length > 0
  );
}

function getOptionalSecret(name) {
  if (
    typeof name !== "string" ||
    !name.trim()
  ) {
    throw new TypeError(
      "Secret name must be a non-empty string."
    );
  }

  const value = process.env[name];

  if (
    typeof value !== "string" ||
    value.length === 0
  ) {
    return null;
  }

  return value;
}

function validateRequiredSecrets(
  secretNames = REQUIRED_SECRET_NAMES
) {
  if (!Array.isArray(secretNames)) {
    throw new TypeError(
      "secretNames must be an array."
    );
  }

  const missingSecrets = [];

  for (const name of secretNames) {
    if (!hasSecret(name)) {
      missingSecrets.push(name);
    }
  }

  if (missingSecrets.length > 0) {
    throw new Error(
      `Missing required secrets: ${missingSecrets.join(
        ", "
      )}`
    );
  }

  return true;
}

function listMissingSecrets(
  secretNames = REQUIRED_SECRET_NAMES
) {
  if (!Array.isArray(secretNames)) {
    throw new TypeError(
      "secretNames must be an array."
    );
  }

  return secretNames.filter(
    (name) => !hasSecret(name)
  );
}

export {
  getSecret,
  hasSecret,
  getOptionalSecret,
  validateRequiredSecrets,
  listMissingSecrets
};
