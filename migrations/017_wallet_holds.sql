-- =========================================================
-- WORTHAPP
-- WALLET HOLDS / SECURITY RESTRICTIONS
-- Migration: 017
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET HOLDS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_holds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    hold_type VARCHAR(40) NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'active'
        CHECK (
            status IN (
                'active',
                'released',
                'expired',
                'cancelled'
            )
        ),

    reason VARCHAR(255) NOT NULL,

    description TEXT,

    amount NUMERIC(36, 18),

    currency VARCHAR(20),

    imposed_by UUID,

    released_by UUID,

    starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    expires_at TIMESTAMPTZ,

    released_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_holds_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_holds_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_holds_imposed_by
        FOREIGN KEY (imposed_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_wallet_holds_released_by
        FOREIGN KEY (released_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_holds_type_not_empty
        CHECK (
            LENGTH(TRIM(hold_type)) > 0
        ),

    CONSTRAINT wallet_holds_reason_not_empty
        CHECK (
            LENGTH(TRIM(reason)) > 0
        ),

    CONSTRAINT wallet_holds_amount_positive
        CHECK (
            amount IS NULL OR amount >= 0
        ),

    CONSTRAINT wallet_holds_expiry_valid
        CHECK (
            expires_at IS NULL
            OR expires_at > starts_at
        ),

    CONSTRAINT wallet_holds_release_valid
        CHECK (
            released_at IS NULL
            OR released_at >= starts_at
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_holds_wallet_id
ON wallet_holds(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_holds_user_id
ON wallet_holds(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_holds_status
ON wallet_holds(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_holds_hold_type
ON wallet_holds(hold_type);

CREATE INDEX IF NOT EXISTS
idx_wallet_holds_starts_at
ON wallet_holds(starts_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_holds_expires_at
ON wallet_holds(expires_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_holds_created_at
ON wallet_holds(created_at);

-- =========================================================
-- ACTIVE WALLET HOLD LOOKUP
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_holds_active_wallet
ON wallet_holds(wallet_id, status)
WHERE status = 'active';

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_wallet_holds_updated_at
ON wallet_holds;

CREATE TRIGGER trg_wallet_holds_updated_at
BEFORE UPDATE ON wallet_holds
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_holds IS
'Security and compliance holds applied to Worthapp wallets.';

COMMENT ON COLUMN wallet_holds.hold_type IS
'Type of wallet restriction or security hold.';

COMMENT ON COLUMN wallet_holds.status IS
'Current lifecycle state of the wallet hold.';

COMMENT ON COLUMN wallet_holds.reason IS
'Reason why the wallet hold was created.';

COMMENT ON COLUMN wallet_holds.amount IS
'Optional amount affected by the hold.';

COMMENT ON COLUMN wallet_holds.imposed_by IS
'User or authorized administrator who imposed the hold.';

COMMENT ON COLUMN wallet_holds.released_by IS
'User or authorized administrator who released the hold.';

COMMENT ON COLUMN wallet_holds.metadata IS
'Additional structured security and compliance information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
