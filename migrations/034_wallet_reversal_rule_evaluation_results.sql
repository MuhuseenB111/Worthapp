-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL RULE EVALUATION RESULTS
-- Migration: 034
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL RULE EVALUATION RESULTS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_rule_evaluation_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    evaluation_id UUID NOT NULL,

    rule_id UUID NOT NULL,

    matched BOOLEAN NOT NULL DEFAULT FALSE,

    match_reason TEXT,

    evaluated_amount NUMERIC(30, 10),

    currency_code VARCHAR(20),

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

    priority INTEGER
        CHECK (
            priority IS NULL
            OR priority >= 0
        ),

    result_status VARCHAR(30) NOT NULL DEFAULT 'evaluated'
        CHECK (
            result_status IN (
                'evaluated',
                'matched',
                'not_matched',
                'failed',
                'superseded'
            )
        ),

    failure_reason TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_rule_evaluation_results_evaluation
        FOREIGN KEY (evaluation_id)
        REFERENCES wallet_reversal_rule_evaluations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_evaluation_results_rule
        FOREIGN KEY (rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_reversal_rule_evaluation_result_status_check
        CHECK (
            (
                result_status = 'matched'
                AND matched = TRUE
            )
            OR
            (
                result_status = 'not_matched'
                AND matched = FALSE
            )
            OR
            result_status IN (
                'evaluated',
                'failed',
                'superseded'
            )
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_results_evaluation
ON wallet_reversal_rule_evaluation_results(evaluation_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_results_rule
ON wallet_reversal_rule_evaluation_results(rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_results_matched
ON wallet_reversal_rule_evaluation_results(matched);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_results_status
ON wallet_reversal_rule_evaluation_results(result_status);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_results_created
ON wallet_reversal_rule_evaluation_results(created_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_results_evaluation_matched
ON wallet_reversal_rule_evaluation_results(evaluation_id, matched);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_results_evaluation_priority
ON wallet_reversal_rule_evaluation_results(evaluation_id, priority);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_rule_evaluation_results IS
'Detailed results produced when wallet reversal approval rules are evaluated.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.evaluation_id IS
'Wallet reversal rule evaluation associated with this result.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.rule_id IS
'Approval rule evaluated during the evaluation process.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.matched IS
'Whether the approval rule matched the reversal being evaluated.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.match_reason IS
'Explanation of why the approval rule matched or did not match.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.evaluated_amount IS
'Amount used when evaluating the approval rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.currency_code IS
'Currency associated with the evaluated amount.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.approval_level IS
'Approval hierarchy level obtained from the evaluated rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.required_approvals IS
'Number of approvals required according to the evaluated rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.requires_admin IS
'Whether administrator approval is required by the evaluated rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.requires_kyc IS
'Whether KYC requirements apply according to the evaluated rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.priority IS
'Evaluation priority of the approval rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.result_status IS
'Current status of this individual rule evaluation result.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.failure_reason IS
'Reason why evaluation of the rule failed, when applicable.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_results.metadata IS
'Additional structured evaluation result information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
