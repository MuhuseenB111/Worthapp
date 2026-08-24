-- =========================================================
-- WORTHAPP
-- WALLET RECONCILIATION
-- Migration: 019
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET RECONCILIATION
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reconciliation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    reconciliation_type VARCHAR(40) NOT NULL DEFAULT 'automatic',

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'running',
                'matched',
                'mismatch',
                'failed'
            )
        ),

    expected_balance NUMERIC(36, 18) NOT NULL DEFAULT 0,

    ledger_balance NUMERIC(36, 18) NOT NULL DEFAULT 0,

    difference NUMERIC(36, 18) NOT NULL DEFAULT 0,

    currency VARCHAR(20),

    transaction_count INTEGER NOT NULL DEFAULT 0,

    discrepancy_count INTEGER NOT NULL DEFAULT 0,

    started_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    error_message TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_reconciliation_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_reconciliation_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_reconciliation_type_not_empty
        CHECK (
            LENGTH(TRIM(reconciliation_type)) > 0
        ),

    CONSTRAINT wallet_reconciliation_expected_non_negative
        CHECK (
            expected_balance >= 0
        ),

    CONSTRAINT wallet_reconciliation_ledger_non_negative
        CHECK (
            ledger_balance >= 0
        ),

    CONSTRAINT wallet_reconciliation_difference_valid
        CHECK (
            difference = ledger_balance - expected_balance
        ),

    CONSTRAINT wallet_reconciliation_counts_valid
        CHECK (
            transaction_count >= 0
            AND discrepancy_count >= 0
        ),

    CONSTRAINT wallet_reconciliation_completed_valid
        CHECK (
            completed_at IS NULL
            OR started_at IS NULL
            OR completed_at >= started_at
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_wallet_id
ON wallet_reconciliation(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_user_id
ON wallet_reconciliation(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_status
ON wallet_reconciliation(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_type
ON wallet_reconciliation(reconciliation_type);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_created_at
ON wallet_reconciliation(created_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_completed_at
ON wallet_reconciliation(completed_at);

-- =========================================================
-- MISMATCH LOOKUP
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_mismatch
ON wallet_reconciliation(wallet_id, status)
WHERE status = 'mismatch';

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_wallet_reconciliation_updated_at
ON wallet_reconciliation;

CREATE TRIGGER trg_wallet_reconciliation_updated_at
BEFORE UPDATE ON wallet_reconciliation
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reconciliation IS
'Reconciliation records used to verify Worthapp wallet balances against ledger balances.';

COMMENT ON COLUMN wallet_reconciliation.reconciliation_type IS
'Source of reconciliation, such as automatic or manual.';

COMMENT ON COLUMN wallet_reconciliation.status IS
'Current reconciliation processing state.';

COMMENT ON COLUMN wallet_reconciliation.expected_balance IS
'Expected wallet balance according to the wallet/accounting system.';

COMMENT ON COLUMN wallet_reconciliation.ledger_balance IS
'Balance calculated from wallet ledger records.';

COMMENT ON COLUMN wallet_reconciliation.difference IS
'Difference between ledger balance and expected balance.';

COMMENT ON COLUMN wallet_reconciliation.discrepancy_count IS
'Number of discrepancies detected during reconciliation.';

COMMENT ON COLUMN wallet_reconciliation.metadata IS
'Additional reconciliation and audit information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
