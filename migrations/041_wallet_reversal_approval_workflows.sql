-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL WORKFLOWS
-- Migration: 041
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL WORKFLOWS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_workflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reversal_id UUID NOT NULL UNIQUE,

    evaluation_id UUID,

    selected_rule_id UUID,

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'routing',
                'awaiting_approval',
                'partially_approved',
                'approved',
                'rejected',
                'cancelled',
                'expired',
                'manual_review',
                'completed',
                'failed'
            )
        ),

    current_approval_level INTEGER NOT NULL DEFAULT 1
        CHECK (current_approval_level > 0),

    total_approval_levels INTEGER NOT NULL DEFAULT 1
        CHECK (total_approval_levels > 0),

    required_approvals INTEGER NOT NULL DEFAULT 1
        CHECK (required_approvals > 0),

    approvals_received INTEGER NOT NULL DEFAULT 0
        CHECK (approvals_received >= 0),

    rejections_received INTEGER NOT NULL DEFAULT 0
        CHECK (rejections_received >= 0),

    pending_approvals INTEGER NOT NULL DEFAULT 0
        CHECK (pending_approvals >= 0),

    requires_admin BOOLEAN NOT NULL DEFAULT FALSE,

    requires_kyc BOOLEAN NOT NULL DEFAULT FALSE,

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

    decision_reason TEXT,

    started_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_approval_workflows_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_workflows_evaluation
        FOREIGN KEY (evaluation_id)
        REFERENCES wallet_reversal_rule_evaluations(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_reversal_approval_workflows_rule
        FOREIGN KEY (selected_rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_reversal_approval_workflows_counts_check
        CHECK (
            approvals_received
            + rejections_received
            + pending_approvals
            <=
            required_approvals
            OR
            required_approvals = 0
        ),

    CONSTRAINT wallet_reversal_approval_workflows_levels_check
        CHECK (
            current_approval_level <= total_approval_levels
        ),

    CONSTRAINT wallet_reversal_approval_workflows_expiry_check
        CHECK (
            expires_at IS NULL
            OR expires_at > created_at
        ),

    CONSTRAINT wallet_reversal_approval_workflows_decision_status_check
        CHECK (
            (
                decision = 'approve'
                AND status IN ('approved', 'completed')
            )
            OR
            (
                decision = 'reject'
                AND status IN ('rejected', 'completed')
            )
            OR
            (
                decision IN ('hold', 'manual_review')
            )
            OR
            decision IS NULL
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflows_status
ON wallet_reversal_approval_workflows(status);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflows_evaluation
ON wallet_reversal_approval_workflows(evaluation_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflows_rule
ON wallet_reversal_approval_workflows(selected_rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflows_level
ON wallet_reversal_approval_workflows(
    current_approval_level
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflows_decision
ON wallet_reversal_approval_workflows(decision);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflows_expires
ON wallet_reversal_approval_workflows(expires_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflows_status_expires
ON wallet_reversal_approval_workflows(
    status,
    expires_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_workflows IS
'Controls the complete approval workflow lifecycle for wallet adjustment reversals.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.reversal_id IS
'Wallet adjustment reversal governed by this approval workflow.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.evaluation_id IS
'Rule evaluation that determined the approval workflow requirements.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.selected_rule_id IS
'Approval rule selected for the reversal workflow.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.status IS
'Current overall state of the wallet reversal approval workflow.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.current_approval_level IS
'Approval hierarchy level currently being processed.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.total_approval_levels IS
'Total number of approval hierarchy levels required.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.required_approvals IS
'Total approvals required for the workflow to proceed.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.approvals_received IS
'Number of approvals successfully received.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.rejections_received IS
'Number of rejection decisions received.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.pending_approvals IS
'Number of approval requests still awaiting decisions.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.requires_admin IS
'Whether administrator participation is required.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.requires_kyc IS
'Whether KYC compliance is required before approval can complete.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.decision IS
'Overall workflow decision.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.decision_reason IS
'Reason supporting the final or intermediate workflow decision.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.started_at IS
'Timestamp when approval processing started.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.approved_at IS
'Timestamp when all required approvals were obtained.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.rejected_at IS
'Timestamp when the workflow was rejected.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.completed_at IS
'Timestamp when the approval workflow fully completed.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.expires_at IS
'Timestamp after which the approval workflow expires.';

COMMENT ON COLUMN wallet_reversal_approval_workflows.metadata IS
'Additional structured workflow information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
