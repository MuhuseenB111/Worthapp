-- =========================================================
-- WORTHAPP
-- USER SETTINGS & PREFERENCES SCHEMA
-- Migration: 003
-- =========================================================

BEGIN;

-- =========================================================
-- USER SETTINGS
-- =========================================================

CREATE TABLE IF NOT EXISTS user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL UNIQUE,

    preferred_language VARCHAR(20) NOT NULL DEFAULT 'en',

    timezone VARCHAR(100) NOT NULL DEFAULT 'UTC',

    theme VARCHAR(30) NOT NULL DEFAULT 'system'
        CHECK (
            theme IN (
                'system',
                'light',
                'dark'
            )
        ),

    email_notifications BOOLEAN NOT NULL DEFAULT TRUE,

    push_notifications BOOLEAN NOT NULL DEFAULT TRUE,

    sms_notifications BOOLEAN NOT NULL DEFAULT FALSE,

    marketing_notifications BOOLEAN NOT NULL DEFAULT FALSE,

    privacy_profile_visibility VARCHAR(30) NOT NULL DEFAULT 'public'
        CHECK (
            privacy_profile_visibility IN (
                'public',
                'private',
                'contacts'
            )
        ),

    two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_settings_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================================
-- USER SETTINGS INDEX
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_user_settings_user_id
    ON user_settings(user_id);

CREATE INDEX IF NOT EXISTS idx_user_settings_language
    ON user_settings(preferred_language);

-- =========================================================
-- USER SETTINGS UPDATED_AT TRIGGER
-- =========================================================
--
-- Reuse the set_updated_at() function from Migration 002
-- if it exists.
-- =========================================================

DROP TRIGGER IF EXISTS trg_user_settings_updated_at
ON user_settings;

CREATE TRIGGER trg_user_settings_updated_at
BEFORE UPDATE ON user_settings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- USER SETTINGS VALIDATION
-- =========================================================

ALTER TABLE user_settings
DROP CONSTRAINT IF EXISTS user_settings_language_not_empty;

ALTER TABLE user_settings
ADD CONSTRAINT user_settings_language_not_empty
CHECK (
    LENGTH(TRIM(preferred_language)) > 0
);

-- =========================================================
-- TIMEZONE VALIDATION
-- =========================================================

ALTER TABLE user_settings
DROP CONSTRAINT IF EXISTS user_settings_timezone_not_empty;

ALTER TABLE user_settings
ADD CONSTRAINT user_settings_timezone_not_empty
CHECK (
    LENGTH(TRIM(timezone)) > 0
);

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
