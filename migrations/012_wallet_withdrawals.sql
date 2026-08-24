-- =========================================================
-- WORTHAPP
-- WALLET WITHDRAWALS
-- Migration: 012
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET WITHDRAWALS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_withdrawals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    wallet_address_id UUID,

    amount NUMERIC(36, 18) NOT NULL,

    fee_amount NUMERIC(36, 18) NOT NULL DEFAULT 0,

    net_amount NUMERIC(36, 18) NOT NULL,

    asset_code VARCHAR(50) NOT NULL,

    destination_address TEXT NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'processing',
                'completed',
                'failed',
                'cancelled',
                'blocked'
            )
        ),

    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    processed_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    failure_reason VARCHAR(255),

    transaction_hash TEXT,

    ip_address INET,

    user_agent TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_withdrawals_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_withdrawals_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_withdrawals_amount_positive
        CHECK (
            amount > 0
        ),

    CONSTRAINT wallet_withdrawals_fee_non_negative
        CHECK (
            fee_amount >= 0
        ),

    CONSTRAINT wallet_withdrawals_net_positive
        CHECK (
            net_amount > 0
        ),

    CONSTRAINT wallet_withdrawals_asset_not_empty
        CHECK (
            LENGTH(TRIM(asset_code)) > 0
        ),

    CONSTRAINT wallet_withdrawals_destination_not_empty
        CHECK (
            LENGTH(TRIM(destination_address)) > 0
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_withdrawals_wallet_id
ON wallet_withdrawals(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_withdrawals_user_id
ON wallet_withdrawals(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_withdrawals_status
ON wallet_withdrawals(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_withdrawals_asset_code
ON wallet_withdrawals(asset_code);

CREATE INDEX IF NOT EXISTS
idx_wallet_withdrawals_created_at
ON wallet_withdrawals(created_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_withdrawals_transaction_hash
ON wallet_withdrawals(transaction_hash);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS
trg_wallet_withdrawals_updated_at
ON wallet_withdrawals;

CREATE TRIGGER
trg_wallet_withdrawals_updated_at
BEFORE UPDATE ON wallet_withdrawals
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_withdrawals IS
'Withdrawal requests initiated from Worthapp user wallets.';

COMMENT ON COLUMN wallet_withdrawals.amount IS
'Gross withdrawal amount requested by the user.';

COMMENT ON COLUMN wallet_withdrawals.fee_amount IS
'Network or platform withdrawal fee.';

COMMENT ON COLUMN wallet_withdrawals.net_amount IS
'Amount sent to the destination after applicable fees.';

COMMENT ON COLUMN wallet_withdrawals.destination_address IS
'External destination wallet address supplied for the withdrawal.';

COMMENT ON COLUMN wallet_withdrawals.transaction_hash IS
'Blockchain transaction hash after successful processing.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
