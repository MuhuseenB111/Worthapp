-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL RULE ACTIONS
-- Migration: 029
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_rule_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    rule_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'updated',
                'activated',
                'deactivated',
                'priority_changed',
                'deleted',
                'restored'
            )
        ),

    previous_values JSONB,
    new_values JSONB,

    reason TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_approval_rule_actions_rule
        FOREIGN KEY (rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_rule_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_rule_actions_rule
ON wallet_reversal_approval_rule_actions(rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_rule_actions_actor
ON wallet_reversal_approval_rule_actions(actor_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_rule_actions_type
ON wallet_reversal_approval_rule_actions(action_type);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_rule_actions_created
ON wallet_reversal_approval_rule_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_rule_actions_rule_created
ON wallet_reversal_approval_rule_actions(rule_id, created_at);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_rule_actions IS
'Audit trail for changes made to wallet reversal approval rules.';

COMMENT ON COLUMN wallet_reversal_approval_rule_actions.rule_id IS
'Approval rule associated with the action.';

COMMENT ON COLUMN wallet_reversal_approval_rule_actions.actor_id IS
'User or authorized actor who performed the action.';

COMMENT ON COLUMN wallet_reversal_approval_rule_actions.action_type IS
'Type of configuration action performed on the approval rule.';

COMMENT ON COLUMN wallet_reversal_approval_rule_actions.previous_values IS
'Rule values before the configuration change.';

COMMENT ON COLUMN wallet_reversal_approval_rule_actions.new_values IS
'Rule values after the configuration change.';

COMMENT ON COLUMN wallet_reversal_approval_rule_actions.reason IS
'Reason for changing the approval rule.';

COMMENT ON COLUMN wallet_reversal_approval_rule_actions.metadata IS
'Additional structured audit information.';

COMMIT;
