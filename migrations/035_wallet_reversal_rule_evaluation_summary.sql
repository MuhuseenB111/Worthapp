-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL RULE EVALUATION SUMMARY
-- Migration: 035
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL RULE EVALUATION SUMMARY
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_rule_evaluation_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    evaluation_id UUID NOT NULL UNIQUE,

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'evaluated',
                'matched',
                'not_matched',
                'approved',
                'rejected',
                'failed',
                'cancelled',
                'completed'
            )
        ),

    total_rules_evaluated INTEGER NOT NULL DEFAULT 0
        CHECK (total_rules_evaluated >= 0),

    matched_rules_count INTEGER NOT NULL DEFAULT 0
        CHECK (matched_rules_count >= 0),

    unmatched_rules_count INTEGER NOT NULL DEFAULT 0
        CHECK (unmatched_rules_count >= 0),

    failed_rules_count INTEGER NOT NULL DEFAULT 0
        CHECK (failed_rules_count >= 0),

    selected_rule_id UUID,

    approval_level INTEGER
        CHECK (
            approval_level IS NULL
            OR approval_level > 0
        ),

    required_approvals INTEGER
        CHECK (
            required_approvals IS NULL
            OR required_approvals > 0
        ),

    requires_admin BOOLEAN,

    requires_kyc BOOLEAN,

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

    evaluated_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_rule_evaluation_summary_evaluation
        FOREIGN KEY (evaluation_id)
        REFERENCES wallet_reversal_rule_evaluations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_evaluation_summary_selected_rule
        FOREIGN KEY (selected_rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_reversal_rule_evaluation_summary_counts_check
        CHECK (
            total_rules_evaluated >=
            matched_rules_count
            + unmatched_rules_count
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_summary_status
ON wallet_reversal_rule_evaluation_summary(status);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_summary_selected_rule
ON wallet_reversal_rule_evaluation_summary(selected_rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_summary_decision
ON wallet_reversal_rule_evaluation_summary(decision);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_summary_evaluated_at
ON wallet_reversal_rule_evaluation_summary(evaluated_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_summary_completed_at
ON wallet_reversal_rule_evaluation_summary(completed_at);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_rule_evaluation_summary IS
'Aggregated summary of wallet reversal approval rule evaluation results.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.evaluation_id IS
'Wallet reversal rule evaluation associated with this summary.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.status IS
'Current overall status of the rule evaluation.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.total_rules_evaluated IS
'Total number of approval rules evaluated.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.matched_rules_count IS
'Number of approval rules that matched the reversal.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.unmatched_rules_count IS
'Number of approval rules that did not match the reversal.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.failed_rules_count IS
'Number of approval rule evaluations that failed.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.selected_rule_id IS
'Approval rule selected as the applicable rule after evaluation.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.approval_level IS
'Approval level required by the selected rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.required_approvals IS
'Number of approvals required by the selected rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.requires_admin IS
'Whether administrator approval is required.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.requires_kyc IS
'Whether KYC requirements apply.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.decision IS
'Overall decision produced by the evaluation process.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.decision_reason IS
'Reason supporting the overall evaluation decision.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.evaluated_at IS
'Timestamp when rule evaluation was completed.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.completed_at IS
'Timestamp when the overall evaluation workflow was completed.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_summary.metadata IS
'Additional structured evaluation summary information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
