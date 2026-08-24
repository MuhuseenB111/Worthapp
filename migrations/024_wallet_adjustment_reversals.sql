-- =========================================================
-- WORTHAPP
-- WALLET ADJUSTMENT REVERSALS
-- Migration: 024
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET ADJUSTMENT REVERSALS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_adjustment_reversals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    adjustment_id UUID NOT NULL,

    application_id UUID,

    wallet_id UUID NOT NULL,

    reversal_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            reversal_status IN (
                'pending',
                'processing',
                'completed',
                'failed',
                'cancelled'
            )
        ),

    amount NUMERIC(36, 18) NOT NULL,

    currency VARCHAR(20),

    original_balance NUMERIC(36, 18),

    balance_after_reversal NUMERIC(36, 18),

    reason TEXT NOT NULL,

    notes TEXT,

    requested_by UUID NOT NULL,

    processed_by UUID,

    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    processed_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    cancelled_at TIMESTAMPTZ,

    failure_reason TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_adjustment_reversals_adjustment
        FOREIGN KEY (adjustment_id)
        REFERENCES wallet_reconciliation_adjustments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_adjustment_reversals_application
        FOREIGN KEY (application_id)
        REFERENCES wallet_adjustment_applications(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_wallet_adjustment_reversals_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_adjustment_reversals_requested_by
        FOREIGN KEY (requested_by)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_wallet_adjustment_reversals_processed_by
        FOREIGN KEY (processed_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_adjustment_reversals_amount_positive
        CHECK (
            amount > 0
        ),

    CONSTRAINT wallet_adjustment_reversals_original_balance_valid
        CHECK (
            original_balance IS NULL
            OR original_balance >= 0
        ),

    CONSTRAINT wallet_adjustment_reversals_balance_after_valid
        CHECK (
            balance_after_reversal IS NULL
            OR balance_after_reversal >= 0
        ),

    CONSTRAINT wallet_adjustment_reversals_reason_not_empty
        CHECK (
            LENGTH(TRIM(reason)) > 0
        ),

    CONSTRAINT wallet_adjustment_reversals_completed_consistency
        CHECK (
            (
                reversal_status = 'completed'
                AND processed_by IS NOT NULL
                AND processed_at IS NOT NULL
            )
            OR reversal_status <> 'completed'
        ),

    CONSTRAINT wallet_adjustment_reversals_failed_consistency
        CHECK (
            (
                reversal_status = 'failed'
                AND failed_at IS NOT NULL
            )
            OR reversal_status <> 'failed'
        ),

    CONSTRAINT wallet_adjustment_reversals_cancelled_consistency
        CHECK (
            (
                reversal_status = 'cancelled'
                AND cancelled_at IS NOT NULL
            )
            OR reversal_status <> 'cancelled'
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_reversals_adjustment
ON wallet_adjustment_reversals(adjustment_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_reversals_application
ON wallet_adjustment_reversals(application_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_reversals_wallet
ON wallet_adjustment_reversals(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_reversals_status
ON wallet_adjustment_reversals(reversal_status);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_reversals_requested_by
ON wallet_adjustment_reversals(requested_by);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_reversals_processed_by
ON wallet_adjustment_reversals(processed_by);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_reversals_created_at
ON wallet_adjustment_reversals(created_at);

-- =========================================================
-- ACTIVE REVERSALS
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_reversals_active
ON wallet_adjustment_reversals(wallet_id, reversal_status)
WHERE reversal_status IN (
    'pending',
    'processing'
);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_wallet_adjustment_reversals_updated_at
ON wallet_adjustment_reversals;

CREATE TRIGGER trg_wallet_adjustment_reversals_updated_at
BEFORE UPDATE ON wallet_adjustment_reversals
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_adjustment_reversals IS
'Tracks reversals of previously applied wallet reconciliation adjustments.';

COMMENT ON COLUMN wallet_adjustment_reversals.adjustment_id IS
'Original reconciliation adjustment being reversed.';

COMMENT ON COLUMN wallet_adjustment_reversals.application_id IS
'Original wallet adjustment application associated with the reversal.';

COMMENT ON COLUMN wallet_adjustment_reversals.wallet_id IS
'Wallet affected by the reversal.';

COMMENT ON COLUMN wallet_adjustment_reversals.reversal_status IS
'Lifecycle status of the reversal operation.';

COMMENT ON COLUMN wallet_adjustment_reversals.amount IS
'Amount being reversed.';

COMMENT ON COLUMN wallet_adjustment_reversals.original_balance IS
'Wallet balance before the reversal is applied.';

COMMENT ON COLUMN wallet_adjustment_reversals.balance_after_reversal IS
'Wallet balance after the reversal is applied.';

COMMENT ON COLUMN wallet_adjustment_reversals.reason IS
'Required reason for reversing the adjustment.';

COMMENT ON COLUMN wallet_adjustment_reversals.requested_by IS
'User or administrator who requested the reversal.';

COMMENT ON COLUMN wallet_adjustment_reversals.processed_by IS
'User or system actor who processed the reversal.';

COMMENT ON COLUMN wallet_adjustment_reversals.metadata IS
'Additional reversal and audit information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
