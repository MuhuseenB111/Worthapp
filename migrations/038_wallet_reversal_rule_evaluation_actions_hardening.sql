-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL RULE EVALUATION ACTIONS HARDENING
-- Migration: 038
-- =========================================================

BEGIN;

-- =========================================================
-- EXTEND EVALUATION ACTION TYPES
-- =========================================================
--
-- Migration 033 created the primary evaluation actions table.
-- Migration 037 attempted to introduce additional action types.
--
-- This migration safely upgrades the original table instead
-- of creating a duplicate table.
-- =========================================================

ALTER TABLE wallet_reversal_rule_evaluation_actions
DROP CONSTRAINT IF EXISTS
wallet_reversal_rule_evaluation_actions_action_type_check;

ALTER TABLE wallet_reversal_rule_evaluation_actions
ADD CONSTRAINT
wallet_reversal_rule_evaluation_actions_action_type_check
CHECK (
    action_type IN (
        'created',
        'started',
        'evaluated',
        'matched',
        'not_matched',
        'approved',
        'rejected',
        'skipped',
        'failed',
        're_evaluated',
        'overridden',
        'completed',
        'cancelled'
    )
);

-- =========================================================
-- ENSURE RESULT SNAPSHOT COLUMNS EXIST
-- =========================================================
--
-- These columns already belong conceptually to the original
-- evaluation action model created by Migration 033.
-- IF NOT EXISTS makes this migration safe if they already exist.
-- =========================================================

ALTER TABLE wallet_reversal_rule_evaluation_actions
ADD COLUMN IF NOT EXISTS previous_result JSONB;

ALTER TABLE wallet_reversal_rule_evaluation_actions
ADD COLUMN IF NOT EXISTS new_result JSONB;

-- =========================================================
-- ADDITIONAL INDEX FOR STATUS TRANSITIONS
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_actions_status_transition
ON wallet_reversal_rule_evaluation_actions(
    previous_status,
    new_status
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.previous_result IS
'Evaluation result snapshot before the recorded action.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_actions.new_result IS
'Evaluation result snapshot after the recorded action.';

COMMENT ON CONSTRAINT
wallet_reversal_rule_evaluation_actions_action_type_check
ON wallet_reversal_rule_evaluation_actions IS
'Allowed lifecycle actions for wallet reversal rule evaluations.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
