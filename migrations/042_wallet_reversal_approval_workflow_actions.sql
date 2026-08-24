-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL WORKFLOW ACTIONS
-- Migration: 042
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL WORKFLOW ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_workflow_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'started',
                'routing_started',
                'routing_completed',
                'approval_requested',
                'approval_received',
                'approval_rejected',
                'level_advanced',
                'level_completed',
                'partially_approved',
                'approved',
                'rejected',
                'manual_review',
                'cancelled',
                'expired',
                'failed',
                'completed',
                'reopened',
                'overridden'
            )
        ),

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    previous_approval_level INTEGER
        CHECK (
            previous_approval_level IS NULL
            OR previous_approval_level > 0
        ),

    new_approval_level INTEGER
        CHECK (
            new_approval_level IS NULL
            OR new_approval_level > 0
        ),

    approvals_received_before INTEGER
        CHECK (
            approvals_received_before IS NULL
            OR approvals_received_before >= 0
        ),

    approvals_received_after INTEGER
        CHECK (
            approvals_received_after IS NULL
            OR approvals_received_after >= 0
        ),

    rejections_received_before INTEGER
        CHECK (
            rejections_received_before IS NULL
            OR rejections_received_before >= 0
        ),

    rejections_received_after INTEGER
        CHECK (
            rejections_received_after IS NULL
            OR rejections_received_after >= 0
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

    reason TEXT,

    notes TEXT,

    previous_state JSONB,

    new_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_approval_workflow_actions_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_workflow_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_workflow_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_workflow
ON wallet_reversal_approval_workflow_actions(workflow_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_reversal
ON wallet_reversal_approval_workflow_actions(reversal_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_actor
ON wallet_reversal_approval_workflow_actions(actor_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_type
ON wallet_reversal_approval_workflow_actions(action_type);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_status
ON wallet_reversal_approval_workflow_actions(new_status);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_level
ON wallet_reversal_approval_workflow_actions(
    workflow_id,
    new_approval_level
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_created
ON wallet_reversal_approval_workflow_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_workflow_created
ON wallet_reversal_approval_workflow_actions(
    workflow_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_workflow_actions_reversal_created
ON wallet_reversal_approval_workflow_actions(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_workflow_actions IS
'Audit trail for lifecycle actions performed during wallet reversal approval workflows.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.workflow_id IS
'Approval workflow associated with this action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.reversal_id IS
'Wallet adjustment reversal associated with the workflow action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.actor_id IS
'User or authorized system actor responsible for the workflow action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.action_type IS
'Type of lifecycle action performed on the approval workflow.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.previous_status IS
'Workflow status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.new_status IS
'Workflow status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.previous_approval_level IS
'Approval level before the workflow action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.new_approval_level IS
'Approval level after the workflow action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.approvals_received_before IS
'Number of approvals received before the action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.approvals_received_after IS
'Number of approvals received after the action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.rejections_received_before IS
'Number of rejections received before the action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.rejections_received_after IS
'Number of rejections received after the action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.decision IS
'Decision associated with the workflow action when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.reason IS
'Reason associated with the workflow action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.notes IS
'Additional information associated with the workflow action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.previous_state IS
'Structured workflow state captured before the action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.new_state IS
'Structured workflow state captured after the action.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_actions.metadata IS
'Additional structured workflow audit information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
