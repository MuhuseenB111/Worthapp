-- =========================================================
-- WORTHAPP
-- WALLET TRANSACTION EVENTS
-- Migration: 014
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET TRANSACTION EVENTS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_transaction_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    transaction_id UUID,

    event_type VARCHAR(50) NOT NULL,

    status VARCHAR(30),

    amount NUMERIC(36, 18),

    asset_code VARCHAR(50),

    description TEXT,

    ip_address INET,

    user_agent TEXT,

    device_id VARCHAR(255),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_transaction_events_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_transaction_events_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_transaction_events_type_not_empty
        CHECK (
            LENGTH(TRIM(event_type)) > 0
        ),

    CONSTRAINT wallet_transaction_events_amount_non_negative
        CHECK (
            amount IS NULL OR amount >= 0
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_transaction_events_wallet_id
ON wallet_transaction_events(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_transaction_events_user_id
ON wallet_transaction_events(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_transaction_events_transaction_id
ON wallet_transaction_events(transaction_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_transaction_events_event_type
ON wallet_transaction_events(event_type);

CREATE INDEX IF NOT EXISTS
idx_wallet_transaction_events_status
ON wallet_transaction_events(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_transaction_events_created_at
ON wallet_transaction_events(created_at);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_transaction_events IS
'Audit trail of important wallet transaction events within Worthapp.';

COMMENT ON COLUMN wallet_transaction_events.event_type IS
'Transaction event such as created, approved, processing, completed, failed or cancelled.';

COMMENT ON COLUMN wallet_transaction_events.transaction_id IS
'Optional reference to the related wallet transaction record.';

COMMENT ON COLUMN wallet_transaction_events.metadata IS
'Additional structured information associated with the transaction event.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
