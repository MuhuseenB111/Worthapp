-- =========================================================
-- WORTHAPP
-- WALLET P2P TRANSFERS
-- Migration: 008
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET TRANSFERS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reference_id VARCHAR(100) NOT NULL UNIQUE,

    sender_user_id UUID NOT NULL,

    receiver_user_id UUID NOT NULL,

    sender_wallet_id UUID NOT NULL,

    receiver_wallet_id UUID NOT NULL,

    currency_code VARCHAR(20) NOT NULL,

    amount NUMERIC(30, 12) NOT NULL,

    fee_amount NUMERIC(30, 12) NOT NULL DEFAULT 0,

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'processing',
                'completed',
                'failed',
                'cancelled',
                'reversed'
            )
        ),

    note TEXT,

    idempotency_key VARCHAR(150),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    completed_at TIMESTAMPTZ,

    CONSTRAINT fk_wallet_transfers_sender_user
        FOREIGN KEY (sender_user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_wallet_transfers_receiver_user
        FOREIGN KEY (receiver_user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_wallet_transfers_sender_wallet
        FOREIGN KEY (sender_wallet_id)
        REFERENCES wallet_accounts(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_wallet_transfers_receiver_wallet
        FOREIGN KEY (receiver_wallet_id)
        REFERENCES wallet_accounts(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_transfer_amount_positive
        CHECK (amount > 0),

    CONSTRAINT wallet_transfer_fee_nonnegative
        CHECK (fee_amount >= 0),

    CONSTRAINT wallet_transfer_sender_receiver_different
        CHECK (sender_wallet_id <> receiver_wallet_id),

    CONSTRAINT wallet_transfer_currency_not_empty
        CHECK (
            LENGTH(TRIM(currency_code)) > 0
        ),

    CONSTRAINT wallet_transfer_reference_not_empty
        CHECK (
            LENGTH(TRIM(reference_id)) > 0
        )
);

-- =========================================================
-- TRANSFER INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_transfers_sender_user_id
ON wallet_transfers(sender_user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_transfers_receiver_user_id
ON wallet_transfers(receiver_user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_transfers_sender_wallet_id
ON wallet_transfers(sender_wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_transfers_receiver_wallet_id
ON wallet_transfers(receiver_wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_transfers_status
ON wallet_transfers(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_transfers_currency
ON wallet_transfers(currency_code);

CREATE INDEX IF NOT EXISTS
idx_wallet_transfers_created_at
ON wallet_transfers(created_at);

-- =========================================================
-- IDEMPOTENCY
-- =========================================================

CREATE UNIQUE INDEX IF NOT EXISTS
idx_wallet_transfers_idempotency
ON wallet_transfers(idempotency_key)
WHERE idempotency_key IS NOT NULL;

-- =========================================================
-- TRANSFER STATUS HISTORY
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_transfer_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    transfer_id UUID NOT NULL,

    previous_status VARCHAR(30),

    new_status VARCHAR(30) NOT NULL,

    reason TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_transfer_status_history_transfer
        FOREIGN KEY (transfer_id)
        REFERENCES wallet_transfers(id)
        ON DELETE CASCADE
);

-- =========================================================
-- STATUS HISTORY INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_transfer_status_history_transfer_id
ON wallet_transfer_status_history(transfer_id);

CREATE INDEX IF NOT EXISTS
idx_transfer_status_history_created_at
ON wallet_transfer_status_history(created_at);

-- =========================================================
-- TRANSFER UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS
trg_wallet_transfers_updated_at
ON wallet_transfers;

CREATE TRIGGER
trg_wallet_transfers_updated_at
BEFORE UPDATE ON wallet_transfers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMPLETED STATUS VALIDATION
-- =========================================================

ALTER TABLE wallet_transfers
DROP CONSTRAINT IF EXISTS
wallet_transfer_completed_at_status_check;

ALTER TABLE wallet_transfers
ADD CONSTRAINT
wallet_transfer_completed_at_status_check
CHECK (
    status <> 'completed'
    OR completed_at IS NOT NULL
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_transfers IS
'Peer-to-peer wallet transfers within Worthapp.';

COMMENT ON TABLE wallet_transfer_status_history IS
'Historical status changes for Worthapp wallet transfers.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
