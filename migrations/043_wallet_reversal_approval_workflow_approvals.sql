-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL WORKFLOW APPROVALS
-- Migration: 043
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL WORKFLOW APPROVALS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_workflow_approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    approval_id UUID,

    approver_id UUID,

    approval_level INTEGER NOT NULL
        CHECK (approval_level > 0),

    approval_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            approval_status IN (
                'pending',
                'requested',
                'approved',
                'rejected',
                'expired',
                'cancelled',
                'skipped',
                'overridden'
            )
        ),

    decision VARCHAR(30)
        CHECK (
            decision IS NULL
            OR decision IN (
                'approve',
                'reject',
                'hold',
                'manual_review'
            )
        ),

    requested_at TIMESTAMPTZ,

    responded_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    reason TEXT,

    notes TEXT,

    decision_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_workflow_approvals_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_workflow_approvals_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_workflow_approvals_approval
        FOREIGN KEY (approval_id)
        REFERENCES wallet_reversal_approvals(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_reversal_workflow_approvals_approver
        FOREIGN KEY (approver_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_reversal_workflow_approvals_dates_check
        CHECK (
            responded_at IS NULL
            OR requested_at IS NULL
            OR responded_at >= requested_at
        ),

    CONSTRAINT wallet_reversal_workflow_approvals_expiry_check
        CHECK (
            expires_at IS NULL
            OR requested_at IS NULL
            OR expires_at >= requested_at
        ),

    CONSTRAINT wallet_reversal_workflow_approvals_decision_status_check
        CHECK (
            (
                approval_status = 'approved'
                AND decision = 'approve'
            )
            OR
            (
                approval_status = 'rejected'
                AND decision = 'reject'
            )
            OR
            approval_status IN (
                'pending',
                'requested',
                'expired',
                'cancelled',
                'skipped',
                'overridden'
            )
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_workflow
ON wallet_reversal_approval_workflow_approvals(workflow_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_reversal
ON wallet_reversal_approval_workflow_approvals(reversal_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_approval
ON wallet_reversal_approval_workflow_approvals(approval_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_approver
ON wallet_reversal_approval_workflow_approvals(approver_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_level
ON wallet_reversal_approval_workflow_approvals(
    workflow_id,
    approval_level
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_status
ON wallet_reversal_approval_workflow_approvals(
    approval_status
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_requested
ON wallet_reversal_approval_workflow_approvals(
    requested_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_responded
ON wallet_reversal_approval_workflow_approvals(
    responded_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_expires
ON wallet_reversal_approval_workflow_approvals(
    expires_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_workflow_status
ON wallet_reversal_approval_workflow_approvals(
    workflow_id,
    approval_status
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approvals_workflow_level
ON wallet_reversal_approval_workflow_approvals(
    workflow_id,
    approval_level
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_workflow_approvals IS
'Approval decisions and approval assignments associated with wallet reversal approval workflows.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.workflow_id IS
'Approval workflow associated with this approval record.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.reversal_id IS
'Wallet adjustment reversal associated with the approval workflow.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.approval_id IS
'Underlying wallet reversal approval record associated with this workflow approval when available.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.approver_id IS
'User responsible for approving or rejecting this workflow approval request.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.approval_level IS
'Approval hierarchy level associated with this approval request.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.approval_status IS
'Current lifecycle status of this workflow approval request.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.decision IS
'Decision recorded for this workflow approval when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.requested_at IS
'Timestamp when approval was requested.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.responded_at IS
'Timestamp when the approver responded.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.expires_at IS
'Timestamp after which the approval request is considered expired.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.reason IS
'Reason associated with the approval decision or workflow state.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.notes IS
'Additional information associated with the approval request or decision.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.decision_metadata IS
'Structured information associated with the approval decision.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approvals.metadata IS
'Additional structured workflow approval information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
