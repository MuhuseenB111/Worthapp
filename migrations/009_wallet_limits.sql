-- =========================================================
-- WORTHAPP
-- WALLET TRANSACTION LIMITS
-- Migration: 009
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET LIMITS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_limits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL UNIQUE,

    currency_code VARCHAR(20) NOT NULL,

    max_transaction_amount NUMERIC(30, 12),

    daily_transfer_limit NUMERIC(30, 12),

    daily_withdrawal_limit NUMERIC(30, 12),

    daily_payment_limit NUMERIC(30, 12),

    monthly_transfer_limit NUMERIC(30, 12),

    monthly_withdrawal_limit NUMERIC(30, 12),

    monthly_payment_limit NUMERIC(30, 12),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_limits_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_limits_currency_not_empty
        CHECK (
            LENGTH(TRIM(currency_code)) > 0
        ),

    CONSTRAINT wallet_limits_max_transaction_positive
        CHECK (
            max_transaction_amount IS NULL
            OR max_transaction_amount > 0
        ),

    CONSTRAINT wallet_limits_daily_transfer_positive
        CHECK (
            daily_transfer_limit IS NULL
            OR daily_transfer_limit > 0
        ),

    CONSTRAINT wallet_limits_daily_withdrawal_positive
        CHECK (
            daily_withdrawal_limit IS NULL
            OR daily_withdrawal_limit > 0
        ),

    CONSTRAINT wallet_limits_daily_payment_positive
        CHECK (
            daily_payment_limit IS NULL
            OR daily_payment_limit > 0
        ),

    CONSTRAINT wallet_limits_monthly_transfer_positive
        CHECK (
            monthly_transfer_limit IS NULL
            OR monthly_transfer_limit > 0
        ),

    CONSTRAINT wallet_limits_monthly_withdrawal_positive
        CHECK (
            monthly_withdrawal_limit IS NULL
            OR monthly_withdrawal_limit > 0
        ),

    CONSTRAINT wallet_limits_monthly_payment_positive
        CHECK (
            monthly_payment_limit IS NULL
            OR monthly_payment_limit > 0
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_limits_user_id
ON wallet_limits(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_limits_currency
ON wallet_limits(currency_code);

CREATE INDEX IF NOT EXISTS
idx_wallet_limits_active
ON wallet_limits(is_active);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS
trg_wallet_limits_updated_at
ON wallet_limits;

CREATE TRIGGER
trg_wallet_limits_updated_at
BEFORE UPDATE ON wallet_limits
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_limits IS
'Transaction and spending limits applied to Worthapp users.';

COMMENT ON COLUMN wallet_limits.max_transaction_amount IS
'Maximum amount allowed for a single transaction.';

COMMENT ON COLUMN wallet_limits.daily_transfer_limit IS
'Maximum total P2P transfer amount allowed per day.';

COMMENT ON COLUMN wallet_limits.daily_withdrawal_limit IS
'Maximum total withdrawal amount allowed per day.';

COMMENT ON COLUMN wallet_limits.daily_payment_limit IS
'Maximum total payment amount allowed per day.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
