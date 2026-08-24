-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL RULE EVALUATION ACTIONS
-- Migration: 037
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS wallet_reversal_rule_evaluation_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    evaluation_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'evaluated',
                'matched',
                'not_matched',
                'skipped',
                'failed',
                're_evaluated',
                'overridden',
                'cancelled'
            )
        ),

    previous_status VARCHAR(20),

    new_status VARCHAR(20),

    reason TEXT,

    notes TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_rule_evaluation_actions_evaluation
        FOREIGN KEY (evaluation_id)
        REFERENCES wallet_reversal_rule_evaluations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_evaluation_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_actions_evaluation
ON wallet_reversal_rule_evaluation_actions(evaluation_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_actions_actor
ON wallet_reversal_rule_evaluation_actions(actor_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_actions_type
ON wallet_reversal_rule_evaluation_actions(action_type);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_actions_created
ON wallet_reversal_rule_evaluation_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_actions_evaluation_created
ON wallet_reversal_rule_evaluation_actions(
    evaluation_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_rule_evaluation_actions IS
'Audit trail for actions performed during wallet reversal approval rule evaluations.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.evaluation_id IS
'Rule evaluation associated with this action.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.actor_id IS
'User or authorized system actor responsible for the action.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.action_type IS
'Type of action performed during the rule evaluation lifecycle.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.previous_status IS
'Evaluation status before the action.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.new_status IS
'Evaluation status after the action.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.reason IS
'Reason associated with the evaluation action.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.notes IS
'Additional information associated with the action.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.metadata IS
'Additional structured audit information.';

COMMIT;
