import {
  createCipheriv,
  createDecipheriv,
  randomBytes
} from "node:crypto";

const ALGORITHM = "aes-256-gcm";
const IV_LENGTH = 12;
const KEY_LENGTH = 32;
const AUTH_TAG_LENGTH = 16;
const VERSION = 1;

function validateKey(key) {
  if (!Buffer.isBuffer(key)) {
    throw new TypeError(
      "Encryption key must be a Buffer."
    );
  }

  if (key.length !== KEY_LENGTH) {
    throw new Error(
      "Encryption key must be exactly 32 bytes."
    );
  }
}

function generateEncryptionKey() {
  return randomBytes(KEY_LENGTH);
}

function encryptText(plaintext, key) {
  validateKey(key);

  if (typeof plaintext !== "string") {
    throw new TypeError(
      "Plaintext must be a string."
    );
  }

  const iv = randomBytes(IV_LENGTH);

  const cipher = createCipheriv(
    ALGORITHM,
    key,
    iv
  );

  const encrypted = Buffer.concat([
    cipher.update(plaintext, "utf8"),
    cipher.final()
  ]);

  const authTag = cipher.getAuthTag();

  return {
    version: VERSION,
    algorithm: ALGORITHM,
    iv: iv.toString("base64"),
    authTag: authTag.toString("base64"),
    ciphertext: encrypted.toString("base64")
  };
}

function decryptText(encryptedData, key) {
  validateKey(key);

  if (
    !encryptedData ||
    typeof encryptedData !== "object"
  ) {
    throw new TypeError(
      "Encrypted data must be an object."
    );
  }

  if (encryptedData.version !== VERSION) {
    throw new Error(
      "Unsupported encryption version."
    );
  }

  if (encryptedData.algorithm !== ALGORITHM) {
    throw new Error(
      "Unsupported encryption algorithm."
    );
  }

  const iv = Buffer.from(
    encryptedData.iv,
    "base64"
  );

  const authTag = Buffer.from(
    encryptedData.authTag,
    "base64"
  );

  const ciphertext = Buffer.from(
    encryptedData.ciphertext,
    "base64"
  );

  if (iv.length !== IV_LENGTH) {
    throw new Error(
      "Invalid encryption IV."
    );
  }

  if (authTag.length !== AUTH_TAG_LENGTH) {
    throw new Error(
      "Invalid authentication tag."
    );
  }

  const decipher = createDecipheriv(
    ALGORITHM,
    key,
    iv
  );

  decipher.setAuthTag(authTag);

  const decrypted = Buffer.concat([
    decipher.update(ciphertext),
    decipher.final()
  ]);

  return decrypted.toString("utf8");
}

function isValidEncryptedData(value) {
  return Boolean(
    value &&
      typeof value === "object" &&
      value.version === VERSION &&
      value.algorithm === ALGORITHM &&
      typeof value.iv === "string" &&
      typeof value.authTag === "string" &&
      typeof value.ciphertext === "string"
  );
}

export {
  generateEncryptionKey,
  encryptText,
  decryptText,
  isValidEncryptedData
};
