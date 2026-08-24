-- =========================================================
-- WORTHAPP
-- WALLET RECONCILIATION ADJUSTMENTS
-- Migration: 021
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET RECONCILIATION ADJUSTMENTS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reconciliation_adjustments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reconciliation_id UUID NOT NULL,

    reconciliation_item_id UUID,

    wallet_id UUID NOT NULL,

    adjustment_type VARCHAR(40) NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'approved',
                'rejected',
                'applied',
                'cancelled'
            )
        ),

    amount NUMERIC(36, 18) NOT NULL,

    currency VARCHAR(20),

    reason TEXT NOT NULL,

    notes TEXT,

    requested_by UUID NOT NULL,

    approved_by UUID,

    applied_by UUID,

    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    approved_at TIMESTAMPTZ,

    applied_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    cancelled_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_adjustments_reconciliation
        FOREIGN KEY (reconciliation_id)
        REFERENCES wallet_reconciliation(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_adjustments_item
        FOREIGN KEY (reconciliation_item_id)
        REFERENCES wallet_reconciliation_items(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_wallet_adjustments_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_adjustments_requested_by
        FOREIGN KEY (requested_by)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_wallet_adjustments_approved_by
        FOREIGN KEY (approved_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_wallet_adjustments_applied_by
        FOREIGN KEY (applied_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_adjustments_type_not_empty
        CHECK (
            LENGTH(TRIM(adjustment_type)) > 0
        ),

    CONSTRAINT wallet_adjustments_reason_not_empty
        CHECK (
            LENGTH(TRIM(reason)) > 0
        ),

    CONSTRAINT wallet_adjustments_amount_positive
        CHECK (
            amount > 0
        ),

    CONSTRAINT wallet_adjustments_approval_consistency
        CHECK (
            (
                status IN ('approved', 'applied')
                AND approved_by IS NOT NULL
                AND approved_at IS NOT NULL
            )
            OR
            status NOT IN ('approved', 'applied')
        ),

    CONSTRAINT wallet_adjustments_applied_consistency
        CHECK (
            (
                status = 'applied'
                AND applied_by IS NOT NULL
                AND applied_at IS NOT NULL
            )
            OR
            status <> 'applied'
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_reconciliation
ON wallet_reconciliation_adjustments(reconciliation_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_item
ON wallet_reconciliation_adjustments(reconciliation_item_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_wallet
ON wallet_reconciliation_adjustments(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_status
ON wallet_reconciliation_adjustments(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_requested_by
ON wallet_reconciliation_adjustments(requested_by);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_approved_by
ON wallet_reconciliation_adjustments(approved_by);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_applied_by
ON wallet_reconciliation_adjustments(applied_by);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_created_at
ON wallet_reconciliation_adjustments(created_at);

-- =========================================================
-- PENDING / ACTIVE ADJUSTMENTS
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustments_active
ON wallet_reconciliation_adjustments(wallet_id, status)
WHERE status IN (
    'pending',
    'approved'
);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_wallet_reconciliation_adjustments_updated_at
ON wallet_reconciliation_adjustments;

CREATE TRIGGER trg_wallet_reconciliation_adjustments_updated_at
BEFORE UPDATE ON wallet_reconciliation_adjustments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reconciliation_adjustments IS
'Approved wallet balance adjustments created from reconciliation discrepancies.';

COMMENT ON COLUMN wallet_reconciliation_adjustments.adjustment_type IS
'Type of wallet adjustment being requested.';

COMMENT ON COLUMN wallet_reconciliation_adjustments.status IS
'Lifecycle state of the reconciliation adjustment.';

COMMENT ON COLUMN wallet_reconciliation_adjustments.amount IS
'Amount to be adjusted.';

COMMENT ON COLUMN wallet_reconciliation_adjustments.reason IS
'Required reason explaining why the adjustment is necessary.';

COMMENT ON COLUMN wallet_reconciliation_adjustments.requested_by IS
'User or administrator who requested the adjustment.';

COMMENT ON COLUMN wallet_reconciliation_adjustments.approved_by IS
'Authorized user who approved the adjustment.';

COMMENT ON COLUMN wallet_reconciliation_adjustments.applied_by IS
'User or system actor that applied the adjustment.';

COMMENT ON COLUMN wallet_reconciliation_adjustments.metadata IS
'Additional audit and reconciliation information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
