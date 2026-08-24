-- =========================================================
-- WORTHAPP
-- WALLET RECONCILIATION ITEMS
-- Migration: 020
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET RECONCILIATION ITEMS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reconciliation_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reconciliation_id UUID NOT NULL,

    wallet_id UUID NOT NULL,

    transaction_id UUID,

    ledger_entry_id UUID,

    item_type VARCHAR(40) NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'investigating',
                'resolved',
                'ignored'
            )
        ),

    expected_amount NUMERIC(36, 18) NOT NULL DEFAULT 0,

    actual_amount NUMERIC(36, 18) NOT NULL DEFAULT 0,

    difference NUMERIC(36, 18) NOT NULL DEFAULT 0,

    currency VARCHAR(20),

    description TEXT,

    resolution TEXT,

    resolved_by UUID,

    resolved_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_reconciliation_items_reconciliation
        FOREIGN KEY (reconciliation_id)
        REFERENCES wallet_reconciliation(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_reconciliation_items_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_reconciliation_items_user
        FOREIGN KEY (resolved_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_reconciliation_items_type_not_empty
        CHECK (
            LENGTH(TRIM(item_type)) > 0
        ),

    CONSTRAINT wallet_reconciliation_items_difference_valid
        CHECK (
            difference = actual_amount - expected_amount
        ),

    CONSTRAINT wallet_reconciliation_items_resolved_valid
        CHECK (
            (
                status = 'resolved'
                AND resolved_at IS NOT NULL
            )
            OR
            status <> 'resolved'
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_reconciliation
ON wallet_reconciliation_items(reconciliation_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_wallet
ON wallet_reconciliation_items(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_transaction
ON wallet_reconciliation_items(transaction_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_ledger_entry
ON wallet_reconciliation_items(ledger_entry_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_status
ON wallet_reconciliation_items(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_type
ON wallet_reconciliation_items(item_type);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_created_at
ON wallet_reconciliation_items(created_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_resolved_by
ON wallet_reconciliation_items(resolved_by);

-- =========================================================
-- OPEN DISCREPANCIES LOOKUP
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_reconciliation_items_open
ON wallet_reconciliation_items(wallet_id, status)
WHERE status IN (
    'open',
    'investigating'
);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_wallet_reconciliation_items_updated_at
ON wallet_reconciliation_items;

CREATE TRIGGER trg_wallet_reconciliation_items_updated_at
BEFORE UPDATE ON wallet_reconciliation_items
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reconciliation_items IS
'Individual reconciliation discrepancies and investigation records for Worthapp wallets.';

COMMENT ON COLUMN wallet_reconciliation_items.item_type IS
'Type of reconciliation discrepancy detected.';

COMMENT ON COLUMN wallet_reconciliation_items.status IS
'Current investigation and resolution state.';

COMMENT ON COLUMN wallet_reconciliation_items.expected_amount IS
'Amount expected by the accounting or wallet system.';

COMMENT ON COLUMN wallet_reconciliation_items.actual_amount IS
'Amount actually found in the ledger or transaction records.';

COMMENT ON COLUMN wallet_reconciliation_items.difference IS
'Difference between actual and expected amounts.';

COMMENT ON COLUMN wallet_reconciliation_items.transaction_id IS
'Optional transaction associated with the discrepancy.';

COMMENT ON COLUMN wallet_reconciliation_items.ledger_entry_id IS
'Optional wallet ledger entry associated with the discrepancy.';

COMMENT ON COLUMN wallet_reconciliation_items.resolution IS
'Explanation of how the discrepancy was resolved.';

COMMENT ON COLUMN wallet_reconciliation_items.metadata IS
'Additional reconciliation investigation information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
