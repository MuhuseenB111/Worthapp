-- =========================================================
-- WORTHAPP
-- WALLET RECONCILIATION ADJUSTMENT APPLICATIONS
-- Migration: 023
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET ADJUSTMENT APPLICATIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_adjustment_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    adjustment_id UUID NOT NULL,

    wallet_id UUID NOT NULL,

    ledger_entry_id UUID,

    application_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            application_status IN (
                'pending',
                'processing',
                'applied',
                'failed',
                'reversed'
            )
        ),

    amount NUMERIC(36, 18) NOT NULL,

    currency VARCHAR(20),

    balance_before NUMERIC(36, 18),

    balance_after NUMERIC(36, 18),

    failure_reason TEXT,

    reversal_reason TEXT,

    applied_by UUID,

    applied_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    reversed_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_adjustment_applications_adjustment
        FOREIGN KEY (adjustment_id)
        REFERENCES wallet_reconciliation_adjustments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_adjustment_applications_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_adjustment_applications_ledger
        FOREIGN KEY (ledger_entry_id)
        REFERENCES wallet_ledger(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_wallet_adjustment_applications_user
        FOREIGN KEY (applied_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_adjustment_applications_amount_positive
        CHECK (
            amount > 0
        ),

    CONSTRAINT wallet_adjustment_applications_balance_before_valid
        CHECK (
            balance_before IS NULL
            OR balance_before >= 0
        ),

    CONSTRAINT wallet_adjustment_applications_balance_after_valid
        CHECK (
            balance_after IS NULL
            OR balance_after >= 0
        ),

    CONSTRAINT wallet_adjustment_applications_applied_consistency
        CHECK (
            (
                application_status = 'applied'
                AND applied_at IS NOT NULL
            )
            OR application_status <> 'applied'
        ),

    CONSTRAINT wallet_adjustment_applications_failed_consistency
        CHECK (
            (
                application_status = 'failed'
                AND failed_at IS NOT NULL
            )
            OR application_status <> 'failed'
        ),

    CONSTRAINT wallet_adjustment_applications_reversed_consistency
        CHECK (
            (
                application_status = 'reversed'
                AND reversed_at IS NOT NULL
            )
            OR application_status <> 'reversed'
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_applications_adjustment
ON wallet_adjustment_applications(adjustment_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_applications_wallet
ON wallet_adjustment_applications(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_applications_ledger
ON wallet_adjustment_applications(ledger_entry_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_applications_status
ON wallet_adjustment_applications(application_status);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_applications_applied_by
ON wallet_adjustment_applications(applied_by);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_applications_created_at
ON wallet_adjustment_applications(created_at);

-- =========================================================
-- ACTIVE APPLICATIONS
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_applications_active
ON wallet_adjustment_applications(wallet_id, application_status)
WHERE application_status IN (
    'pending',
    'processing'
);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_wallet_adjustment_applications_updated_at
ON wallet_adjustment_applications;

CREATE TRIGGER trg_wallet_adjustment_applications_updated_at
BEFORE UPDATE ON wallet_adjustment_applications
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_adjustment_applications IS
'Tracks the application of approved reconciliation adjustments to wallet balances and ledger records.';

COMMENT ON COLUMN wallet_adjustment_applications.adjustment_id IS
'Reconciliation adjustment being applied.';

COMMENT ON COLUMN wallet_adjustment_applications.wallet_id IS
'Wallet receiving the adjustment.';

COMMENT ON COLUMN wallet_adjustment_applications.ledger_entry_id IS
'Ledger entry created by the adjustment application when available.';

COMMENT ON COLUMN wallet_adjustment_applications.application_status IS
'Lifecycle status of the wallet adjustment application.';

COMMENT ON COLUMN wallet_adjustment_applications.amount IS
'Amount applied to the wallet.';

COMMENT ON COLUMN wallet_adjustment_applications.balance_before IS
'Wallet balance immediately before the adjustment.';

COMMENT ON COLUMN wallet_adjustment_applications.balance_after IS
'Wallet balance immediately after the adjustment.';

COMMENT ON COLUMN wallet_adjustment_applications.metadata IS
'Additional application and audit information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
