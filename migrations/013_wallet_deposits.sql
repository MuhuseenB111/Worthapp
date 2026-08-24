-- =========================================================
-- WORTHAPP
-- WALLET DEPOSITS
-- Migration: 013
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET DEPOSITS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_deposits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    wallet_address_id UUID,

    amount NUMERIC(36, 18) NOT NULL,

    asset_code VARCHAR(50) NOT NULL,

    source_address TEXT,

    transaction_hash TEXT,

    block_number BIGINT,

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'confirming',
                'confirmed',
                'failed',
                'reversed'
            )
        ),

    confirmations INTEGER NOT NULL DEFAULT 0
        CHECK (
            confirmations >= 0
        ),

    required_confirmations INTEGER NOT NULL DEFAULT 1
        CHECK (
            required_confirmations > 0
        ),

    detected_at TIMESTAMPTZ,

    confirmed_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    failure_reason VARCHAR(255),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_deposits_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_deposits_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_deposits_amount_positive
        CHECK (
            amount > 0
        ),

    CONSTRAINT wallet_deposits_asset_not_empty
        CHECK (
            LENGTH(TRIM(asset_code)) > 0
        )
);

-- =========================================================
-- DEPOSIT INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_deposits_wallet_id
ON wallet_deposits(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_deposits_user_id
ON wallet_deposits(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_deposits_status
ON wallet_deposits(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_deposits_asset_code
ON wallet_deposits(asset_code);

CREATE INDEX IF NOT EXISTS
idx_wallet_deposits_created_at
ON wallet_deposits(created_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_deposits_transaction_hash
ON wallet_deposits(transaction_hash);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS
trg_wallet_deposits_updated_at
ON wallet_deposits;

CREATE TRIGGER
trg_wallet_deposits_updated_at
BEFORE UPDATE ON wallet_deposits
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_deposits IS
'External deposits received by Worthapp user wallets.';

COMMENT ON COLUMN wallet_deposits.amount IS
'Amount of the asset received by the wallet.';

COMMENT ON COLUMN wallet_deposits.source_address IS
'External blockchain address that sent the deposit.';

COMMENT ON COLUMN wallet_deposits.transaction_hash IS
'Blockchain transaction hash associated with the deposit.';

COMMENT ON COLUMN wallet_deposits.confirmations IS
'Number of blockchain confirmations currently detected.';

COMMENT ON COLUMN wallet_deposits.required_confirmations IS
'Minimum confirmations required before the deposit is considered confirmed.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
