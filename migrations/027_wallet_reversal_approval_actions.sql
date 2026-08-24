-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL ACTIONS
-- Migration: 027
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    approval_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'requested',
                'reviewed',
                'approved',
                'rejected',
                'cancelled',
                'expired',
                'reopened'
            )
        ),

    previous_status VARCHAR(20),

    new_status VARCHAR(20),

    reason TEXT,

    notes TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_approval_actions_approval
        FOREIGN KEY (approval_id)
        REFERENCES wallet_reversal_approvals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_actions_approval
ON wallet_reversal_approval_actions(approval_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_actions_actor
ON wallet_reversal_approval_actions(actor_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_actions_type
ON wallet_reversal_approval_actions(action_type);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_actions_created
ON wallet_reversal_approval_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_actions_approval_created
ON wallet_reversal_approval_actions(approval_id, created_at);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_actions IS
'Audit trail for actions performed during wallet reversal approval workflows.';

COMMENT ON COLUMN wallet_reversal_approval_actions.approval_id IS
'Approval request associated with this action.';

COMMENT ON COLUMN wallet_reversal_approval_actions.actor_id IS
'User or authorized actor responsible for the action.';

COMMENT ON COLUMN wallet_reversal_approval_actions.action_type IS
'Type of approval workflow action performed.';

COMMENT ON COLUMN wallet_reversal_approval_actions.previous_status IS
'Approval status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_actions.new_status IS
'Approval status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_actions.reason IS
'Reason associated with the action.';

COMMENT ON COLUMN wallet_reversal_approval_actions.notes IS
'Additional information about the action.';

COMMENT ON COLUMN wallet_reversal_approval_actions.metadata IS
'Additional structured audit information.';

COMMIT;
