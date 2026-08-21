import {
  randomBytes,
  scrypt,
  timingSafeEqual
} from "node:crypto";

import {
  promisify
} from "node:util";

const scryptAsync = promisify(scrypt);

const HASH_ALGORITHM = "scrypt";

const SALT_LENGTH = 16;
const KEY_LENGTH = 64;

const SCRYPT_OPTIONS = {
  N: 16384,
  r: 8,
  p: 1
};

const PASSWORD_MIN_LENGTH = 12;
const PASSWORD_MAX_LENGTH = 128;

function validatePassword(password) {
  if (typeof password !== "string") {
    throw new TypeError(
      "Password must be a string."
    );
  }

  if (
    password.length < PASSWORD_MIN_LENGTH
  ) {
    throw new Error(
      `Password must contain at least ${PASSWORD_MIN_LENGTH} characters.`
    );
  }

  if (
    password.length > PASSWORD_MAX_LENGTH
  ) {
    throw new Error(
      `Password must not exceed ${PASSWORD_MAX_LENGTH} characters.`
    );
  }
}

async function hashPassword(password) {
  validatePassword(password);

  const salt = randomBytes(SALT_LENGTH);

  const derivedKey = await scryptAsync(
    password,
    salt,
    KEY_LENGTH,
    SCRYPT_OPTIONS
  );

  return [
    HASH_ALGORITHM,
    SCRYPT_OPTIONS.N,
    SCRYPT_OPTIONS.r,
    SCRYPT_OPTIONS.p,
    salt.toString("base64"),
    Buffer.from(derivedKey).toString("base64")
  ].join("$");
}

function parsePasswordHash(passwordHash) {
  if (
    typeof passwordHash !== "string" ||
    !passwordHash.trim()
  ) {
    throw new Error(
      "Invalid password hash."
    );
  }

  const parts = passwordHash.split("$");

  if (parts.length !== 6) {
    throw new Error(
      "Invalid password hash format."
    );
  }

  const [
    algorithm,
    nValue,
    rValue,
    pValue,
    saltValue,
    keyValue
  ] = parts;

  if (algorithm !== HASH_ALGORITHM) {
    throw new Error(
      "Unsupported password hash algorithm."
    );
  }

  const N = Number(nValue);
  const r = Number(rValue);
  const p = Number(pValue);

  if (
    !Number.isInteger(N) ||
    !Number.isInteger(r) ||
    !Number.isInteger(p) ||
    N <= 1 ||
    r <= 0 ||
    p <= 0
  ) {
    throw new Error(
      "Invalid password hash parameters."
    );
  }

  const salt = Buffer.from(
    saltValue,
    "base64"
  );

  const storedKey = Buffer.from(
    keyValue,
    "base64"
  );

  if (salt.length !== SALT_LENGTH) {
    throw new Error(
      "Invalid password salt."
    );
  }

  if (storedKey.length !== KEY_LENGTH) {
    throw new Error(
      "Invalid password hash key."
    );
  }

  return {
    algorithm,
    N,
    r,
    p,
    salt,
    storedKey
  };
}

async function verifyPassword(
  password,
  passwordHash
) {
  validatePassword(password);

  const {
    N,
    r,
    p,
    salt,
    storedKey
  } = parsePasswordHash(passwordHash);

  const derivedKey = await scryptAsync(
    password,
    salt,
    storedKey.length,
    {
      N,
      r,
      p
    }
  );

  const derivedKeyBuffer =
    Buffer.from(derivedKey);

  if (
    derivedKeyBuffer.length !==
    storedKey.length
  ) {
    return false;
  }

  return timingSafeEqual(
    derivedKeyBuffer,
    storedKey
  );
}

function isPasswordHash(value) {
  if (
    typeof value !== "string"
  ) {
    return false;
  }

  try {
    parsePasswordHash(value);
    return true;
  } catch {
    return false;
  }
}

export {
  hashPassword,
  verifyPassword,
  isPasswordHash
};
