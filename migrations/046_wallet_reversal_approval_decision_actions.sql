-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION ACTIONS
-- Migration: 046
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL DECISION ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    decision_id UUID NOT NULL,

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'submitted',
                'reviewed',
                'validated',
                'accepted',
                'rejected',
                'held',
                'escalated',
                'overridden',
                'reopened',
                'cancelled',
                'superseded',
                'completed',
                'failed'
            )
        ),

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    previous_decision VARCHAR(30)
        CHECK (
            previous_decision IS NULL
            OR previous_decision IN (
                'approve',
                'reject',
                'hold',
                'manual_review'
            )
        ),

    new_decision VARCHAR(30)
        CHECK (
            new_decision IS NULL
            OR new_decision IN (
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

    CONSTRAINT fk_reversal_approval_decision_actions_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decision_actions_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decision_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decision_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_decision
ON wallet_reversal_approval_decision_actions(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_workflow
ON wallet_reversal_approval_decision_actions(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_reversal
ON wallet_reversal_approval_decision_actions(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_actor
ON wallet_reversal_approval_decision_actions(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_type
ON wallet_reversal_approval_decision_actions(
    action_type
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_status
ON wallet_reversal_approval_decision_actions(
    new_status
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_created
ON wallet_reversal_approval_decision_actions(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_decision_created
ON wallet_reversal_approval_decision_actions(
    decision_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_workflow_created
ON wallet_reversal_approval_decision_actions(
    workflow_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_actions_reversal_created
ON wallet_reversal_approval_decision_actions(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_actions IS
'Audit trail of lifecycle actions performed against wallet reversal approval decisions.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.decision_id IS
'Approval decision associated with this action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.workflow_id IS
'Approval workflow associated with the decision action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.reversal_id IS
'Wallet adjustment reversal associated with the decision action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.actor_id IS
'User or authorized system actor responsible for the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.action_type IS
'Lifecycle action performed against the approval decision.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.previous_status IS
'Decision status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.new_status IS
'Decision status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.previous_decision IS
'Decision value before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.new_decision IS
'Decision value after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.reason IS
'Reason associated with the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.notes IS
'Additional information associated with the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.previous_state IS
'Structured decision state captured before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.new_state IS
'Structured decision state captured after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.metadata IS
'Additional structured audit information associated with the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_actions.created_at IS
'Timestamp at which the action was recorded.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
