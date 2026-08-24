-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL RULE ASSIGNMENT ACTIONS
-- Migration: 031
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_rule_assignment_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    assignment_id UUID NOT NULL,

    rule_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'updated',
                'activated',
                'deactivated',
                'revoked',
                'restored'
            )
        ),

    previous_values JSONB,

    new_values JSONB,

    reason TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_assignment_actions_assignment
        FOREIGN KEY (assignment_id)
        REFERENCES wallet_reversal_approval_rule_assignments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_assignment_actions_rule
        FOREIGN KEY (rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_assignment_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_assignment_actions_assignment
ON wallet_reversal_approval_rule_assignment_actions(assignment_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_assignment_actions_rule
ON wallet_reversal_approval_rule_assignment_actions(rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_assignment_actions_actor
ON wallet_reversal_approval_rule_assignment_actions(actor_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_assignment_actions_type
ON wallet_reversal_approval_rule_assignment_actions(action_type);

CREATE INDEX IF NOT EXISTS
idx_reversal_assignment_actions_created
ON wallet_reversal_approval_rule_assignment_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_assignment_actions_assignment_created
ON wallet_reversal_approval_rule_assignment_actions(
    assignment_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_rule_assignment_actions IS
'Audit trail for changes made to wallet reversal approval rule assignments.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignment_actions.assignment_id IS
'Assignment associated with the recorded action.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignment_actions.rule_id IS
'Approval rule associated with the assignment action.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignment_actions.actor_id IS
'User or authorized actor who performed the assignment action.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignment_actions.action_type IS
'Type of action performed on the approval rule assignment.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignment_actions.previous_values IS
'Assignment values before the configuration change.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignment_actions.new_values IS
'Assignment values after the configuration change.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignment_actions.reason IS
'Reason for changing the approval rule assignment.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignment_actions.metadata IS
'Additional structured audit information.';

COMMIT;
