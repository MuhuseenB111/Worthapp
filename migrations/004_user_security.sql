-- =========================================================
-- WORTHAPP
-- USER SECURITY & TRUSTED DEVICES SCHEMA
-- Migration: 004
-- =========================================================

BEGIN;

-- =========================================================
-- TWO-FACTOR AUTHENTICATION
-- =========================================================
--
-- Stores the security configuration for each user.
--
-- IMPORTANT:
-- secret_encrypted must contain an application-encrypted
-- secret. Never store a raw 2FA secret in production.
-- =========================================================

CREATE TABLE IF NOT EXISTS user_two_factor_auth (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL UNIQUE,

    method VARCHAR(30) NOT NULL DEFAULT 'totp'
        CHECK (
            method IN (
                'totp'
            )
        ),

    secret_encrypted TEXT,

    enabled BOOLEAN NOT NULL DEFAULT FALSE,

    verified_at TIMESTAMPTZ,

    last_used_at TIMESTAMPTZ,

    backup_codes JSONB NOT NULL DEFAULT '[]'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_two_factor_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================================
-- TWO-FACTOR INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_user_two_factor_user_id
    ON user_two_factor_auth(user_id);

CREATE INDEX IF NOT EXISTS idx_user_two_factor_enabled
    ON user_two_factor_auth(enabled);

-- =========================================================
-- TWO-FACTOR UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_user_two_factor_updated_at
ON user_two_factor_auth;

CREATE TRIGGER trg_user_two_factor_updated_at
BEFORE UPDATE ON user_two_factor_auth
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- TRUSTED DEVICES
-- =========================================================
--
-- Allows a verified device to be remembered securely.
--
-- Only a HASH of the device token should be stored.
-- =========================================================

CREATE TABLE IF NOT EXISTS trusted_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    device_token_hash TEXT NOT NULL UNIQUE,

    device_name VARCHAR(150),

    device_type VARCHAR(50),

    operating_system VARCHAR(100),

    browser VARCHAR(100),

    ip_address INET,

    user_agent TEXT,

    last_used_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    expires_at TIMESTAMPTZ,

    revoked_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_trusted_devices_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================================
-- TRUSTED DEVICE INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_trusted_devices_user_id
    ON trusted_devices(user_id);

CREATE INDEX IF NOT EXISTS idx_trusted_devices_expires_at
    ON trusted_devices(expires_at);

CREATE INDEX IF NOT EXISTS idx_trusted_devices_revoked_at
    ON trusted_devices(revoked_at);

CREATE INDEX IF NOT EXISTS idx_trusted_devices_last_used_at
    ON trusted_devices(last_used_at);

-- =========================================================
-- SECURITY EVENTS
-- =========================================================
--
-- Central security activity log.
--
-- Examples:
-- login_success
-- login_failed
-- password_changed
-- password_reset
-- two_factor_enabled
-- two_factor_disabled
-- trusted_device_added
-- trusted_device_revoked
-- email_verified
-- suspicious_activity
-- account_locked
-- account_unlocked
-- =========================================================

CREATE TABLE IF NOT EXISTS security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID,

    event_type VARCHAR(100) NOT NULL,

    severity VARCHAR(30) NOT NULL DEFAULT 'info'
        CHECK (
            severity IN (
                'info',
                'warning',
                'critical'
            )
        ),

    ip_address INET,

    user_agent TEXT,

    device_id UUID,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_security_events_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);

-- =========================================================
-- SECURITY EVENT INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_security_events_user_id
    ON security_events(user_id);

CREATE INDEX IF NOT EXISTS idx_security_events_type
    ON security_events(event_type);

CREATE INDEX IF NOT EXISTS idx_security_events_severity
    ON security_events(severity);

CREATE INDEX IF NOT EXISTS idx_security_events_created_at
    ON security_events(created_at);

CREATE INDEX IF NOT EXISTS idx_security_events_device_id
    ON security_events(device_id);

-- =========================================================
-- ACCOUNT SECURITY STATUS
-- =========================================================
--
-- Keeps account-level security controls separate from
-- authentication credentials.
-- =========================================================

CREATE TABLE IF NOT EXISTS account_security_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL UNIQUE,

    failed_login_count INTEGER NOT NULL DEFAULT 0
        CHECK (failed_login_count >= 0),

    last_failed_login_at TIMESTAMPTZ,

    locked_until TIMESTAMPTZ,

    password_changed_at TIMESTAMPTZ,

    security_review_required BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_account_security_status_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================================
-- ACCOUNT SECURITY INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_account_security_status_user_id
    ON account_security_status(user_id);

CREATE INDEX IF NOT EXISTS idx_account_security_status_locked_until
    ON account_security_status(locked_until);

CREATE INDEX IF NOT EXISTS idx_account_security_status_review
    ON account_security_status(security_review_required);

-- =========================================================
-- ACCOUNT SECURITY UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_account_security_status_updated_at
ON account_security_status;

CREATE TRIGGER trg_account_security_status_updated_at
BEFORE UPDATE ON account_security_status
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- SECURITY DEFAULT VALIDATION
-- =========================================================

ALTER TABLE user_two_factor_auth
DROP CONSTRAINT IF EXISTS user_two_factor_method_not_empty;

ALTER TABLE user_two_factor_auth
ADD CONSTRAINT user_two_factor_method_not_empty
CHECK (
    LENGTH(TRIM(method)) > 0
);

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
