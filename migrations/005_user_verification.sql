-- =========================================================
-- WORTHAPP
-- USER VERIFICATION & IDENTITY SCHEMA
-- Migration: 005
-- =========================================================

BEGIN;

-- =========================================================
-- USER VERIFICATIONS
-- =========================================================
--
-- Stores the verification state of a Worthapp user.
--
-- IMPORTANT:
-- Sensitive identity documents should NOT be stored directly
-- inside this table.
--
-- Use secure external/object storage later and store only
-- safe references and verification metadata here.
-- =========================================================

CREATE TABLE IF NOT EXISTS user_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    verification_type VARCHAR(50) NOT NULL DEFAULT 'identity'
        CHECK (
            verification_type IN (
                'identity',
                'address',
                'business',
                'age'
            )
        ),

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'submitted',
                'under_review',
                'approved',
                'rejected',
                'expired',
                'cancelled'
            )
        ),

    provider VARCHAR(100),

    provider_reference TEXT,

    country_code VARCHAR(10),

    document_type VARCHAR(50),

    document_reference TEXT,

    submitted_at TIMESTAMPTZ,

    reviewed_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    rejection_reason TEXT,

    reviewer_user_id UUID,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_verifications_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_verifications_reviewer
        FOREIGN KEY (reviewer_user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);

-- =========================================================
-- USER VERIFICATION INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_user_verifications_user_id
    ON user_verifications(user_id);

CREATE INDEX IF NOT EXISTS idx_user_verifications_status
    ON user_verifications(status);

CREATE INDEX IF NOT EXISTS idx_user_verifications_type
    ON user_verifications(verification_type);

CREATE INDEX IF NOT EXISTS idx_user_verifications_country
    ON user_verifications(country_code);

CREATE INDEX IF NOT EXISTS idx_user_verifications_reviewer
    ON user_verifications(reviewer_user_id);

CREATE INDEX IF NOT EXISTS idx_user_verifications_created_at
    ON user_verifications(created_at);

CREATE INDEX IF NOT EXISTS idx_user_verifications_expires_at
    ON user_verifications(expires_at);

-- =========================================================
-- VERIFICATION UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_user_verifications_updated_at
ON user_verifications;

CREATE TRIGGER trg_user_verifications_updated_at
BEFORE UPDATE ON user_verifications
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- VERIFICATION REQUEST HISTORY
-- =========================================================
--
-- Keeps an immutable-style history of important
-- verification status changes.
-- =========================================================

CREATE TABLE IF NOT EXISTS verification_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    verification_id UUID NOT NULL,

    user_id UUID NOT NULL,

    event_type VARCHAR(100) NOT NULL,

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    performed_by UUID,

    reason TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_verification_events_verification
        FOREIGN KEY (verification_id)
        REFERENCES user_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_events_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_events_performer
        FOREIGN KEY (performed_by)
        REFERENCES users(id)
        ON DELETE SET NULL
);

-- =========================================================
-- VERIFICATION EVENT INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_verification_events_verification_id
    ON verification_events(verification_id);

CREATE INDEX IF NOT EXISTS idx_verification_events_user_id
    ON verification_events(user_id);

CREATE INDEX IF NOT EXISTS idx_verification_events_event_type
    ON verification_events(event_type);

CREATE INDEX IF NOT EXISTS idx_verification_events_created_at
    ON verification_events(created_at);

-- =========================================================
-- USER VERIFICATION SUMMARY
-- =========================================================
--
-- Provides a quick account-level verification state.
-- =========================================================

CREATE TABLE IF NOT EXISTS user_verification_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL UNIQUE,

    identity_verified BOOLEAN NOT NULL DEFAULT FALSE,

    address_verified BOOLEAN NOT NULL DEFAULT FALSE,

    business_verified BOOLEAN NOT NULL DEFAULT FALSE,

    age_verified BOOLEAN NOT NULL DEFAULT FALSE,

    overall_status VARCHAR(30) NOT NULL DEFAULT 'unverified'
        CHECK (
            overall_status IN (
                'unverified',
                'pending',
                'verified',
                'restricted'
            )
        ),

    last_verified_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_verification_status_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================================
-- VERIFICATION SUMMARY INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_user_verification_status_user_id
    ON user_verification_status(user_id);

CREATE INDEX IF NOT EXISTS idx_user_verification_status_overall
    ON user_verification_status(overall_status);

CREATE INDEX IF NOT EXISTS idx_user_verification_status_identity
    ON user_verification_status(identity_verified);

-- =========================================================
-- VERIFICATION SUMMARY UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_user_verification_status_updated_at
ON user_verification_status;

CREATE TRIGGER trg_user_verification_status_updated_at
BEFORE UPDATE ON user_verification_status
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- BASIC DATA VALIDATION
-- =========================================================

ALTER TABLE user_verifications
DROP CONSTRAINT IF EXISTS user_verifications_country_not_empty;

ALTER TABLE user_verifications
ADD CONSTRAINT user_verifications_country_not_empty
CHECK (
    country_code IS NULL
    OR LENGTH(TRIM(country_code)) > 0
);

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
