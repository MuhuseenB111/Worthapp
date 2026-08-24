-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVALS
-- Migration: 026
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVALS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reversal_id UUID NOT NULL,

    approver_id UUID,

    approval_level INTEGER NOT NULL DEFAULT 1
        CHECK (approval_level > 0),

    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'approved',
                'rejected',
                'cancelled',
                'expired'
            )
        ),

    decision_reason TEXT,

    notes TEXT,

    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    decided_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    CONSTRAINT fk_wallet_reversal_approvals_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_reversal_approvals_approver
        FOREIGN KEY (approver_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_reversal_approval_decision_check
        CHECK (
            (
                status IN ('approved', 'rejected')
                AND approver_id IS NOT NULL
                AND decided_at IS NOT NULL
            )
            OR
            status IN ('pending', 'cancelled', 'expired')
        ),

    CONSTRAINT wallet_reversal_approval_expiry_check
        CHECK (
            expires_at IS NULL
            OR expires_at > requested_at
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_approvals_reversal
ON wallet_reversal_approvals(reversal_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_approvals_approver
ON wallet_reversal_approvals(approver_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_approvals_status
ON wallet_reversal_approvals(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_approvals_requested_at
ON wallet_reversal_approvals(requested_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_approvals_reversal_level
ON wallet_reversal_approvals(reversal_id, approval_level);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approvals IS
'Approval workflow for wallet adjustment reversals.';

COMMENT ON COLUMN wallet_reversal_approvals.reversal_id IS
'Wallet adjustment reversal requiring approval.';

COMMENT ON COLUMN wallet_reversal_approvals.approver_id IS
'Authorized user who makes the approval decision.';

COMMENT ON COLUMN wallet_reversal_approvals.approval_level IS
'Approval hierarchy level required for the reversal.';

COMMENT ON COLUMN wallet_reversal_approvals.status IS
'Current status of the reversal approval request.';

COMMENT ON COLUMN wallet_reversal_approvals.decision_reason IS
'Reason for approval or rejection.';

COMMENT ON COLUMN wallet_reversal_approvals.notes IS
'Additional information associated with the approval.';

COMMENT ON COLUMN wallet_reversal_approvals.metadata IS
'Additional structured approval information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
