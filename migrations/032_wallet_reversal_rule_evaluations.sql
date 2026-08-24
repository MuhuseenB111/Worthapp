-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL RULE EVALUATIONS
-- Migration: 032
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS wallet_reversal_rule_evaluations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reversal_id UUID NOT NULL,

    rule_id UUID NOT NULL,

    evaluation_status VARCHAR(20) NOT NULL DEFAULT 'matched'
        CHECK (
            evaluation_status IN (
                'matched',
                'not_matched',
                'skipped',
                'failed'
            )
        ),

    evaluation_order INTEGER NOT NULL DEFAULT 1
        CHECK (evaluation_order > 0),

    matched_amount BOOLEAN,

    matched_currency BOOLEAN,

    matched_kyc BOOLEAN,

    matched_admin_requirement BOOLEAN,

    matched_active_status BOOLEAN,

    matched_assignment BOOLEAN,

    evaluation_reason TEXT,

    evaluated_by UUID,

    evaluated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    CONSTRAINT fk_reversal_rule_evaluations_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_evaluations_rule
        FOREIGN KEY (rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_evaluations_evaluator
        FOREIGN KEY (evaluated_by)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluations_reversal
ON wallet_reversal_rule_evaluations(reversal_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluations_rule
ON wallet_reversal_rule_evaluations(rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluations_status
ON wallet_reversal_rule_evaluations(evaluation_status);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluations_order
ON wallet_reversal_rule_evaluations(
    reversal_id,
    evaluation_order
);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluations_evaluated_at
ON wallet_reversal_rule_evaluations(evaluated_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluations_reversal_status
ON wallet_reversal_rule_evaluations(
    reversal_id,
    evaluation_status
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_rule_evaluations IS
'Records how wallet reversal approval rules were evaluated for each reversal.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.reversal_id IS
'Wallet adjustment reversal for which the approval rule was evaluated.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.rule_id IS
'Approval rule evaluated against the wallet reversal.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.evaluation_status IS
'Result of evaluating the approval rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.evaluation_order IS
'Order in which approval rules were evaluated based on their priority.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.matched_amount IS
'Whether the reversal amount satisfied the rule amount range.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.matched_currency IS
'Whether the reversal currency satisfied the rule currency requirement.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.matched_kyc IS
'Whether the wallet owner satisfied the rule KYC requirement.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.matched_admin_requirement IS
'Whether the administrator requirement was satisfied.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.matched_active_status IS
'Whether the approval rule was active during evaluation.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.matched_assignment IS
'Whether an authorized user or role assignment satisfied the rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.evaluation_reason IS
'Explanation of the rule evaluation result.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.evaluated_by IS
'User or authorized system actor responsible for the evaluation.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.evaluated_at IS
'Timestamp when the approval rule was evaluated.';

COMMENT ON COLUMN wallet_reversal_rule_evaluations.metadata IS
'Additional structured evaluation information.';

COMMIT;
