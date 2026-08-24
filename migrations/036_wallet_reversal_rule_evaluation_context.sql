-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL RULE EVALUATION CONTEXT
-- Migration: 036
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL RULE EVALUATION CONTEXT
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_rule_evaluation_context (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    evaluation_id UUID NOT NULL UNIQUE,

    reversal_id UUID NOT NULL,

    rule_id UUID NOT NULL,

    amount NUMERIC(30, 10),

    currency_code VARCHAR(20),

    wallet_owner_id UUID,

    kyc_status VARCHAR(30),

    kyc_verified BOOLEAN,

    admin_required BOOLEAN,

    admin_requirement_satisfied BOOLEAN,

    assignment_required BOOLEAN,

    assignment_satisfied BOOLEAN,

    rule_active BOOLEAN,

    rule_priority INTEGER
        CHECK (
            rule_priority IS NULL
            OR rule_priority >= 0
        ),

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

    context_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,

    captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_rule_evaluation_context_evaluation
        FOREIGN KEY (evaluation_id)
        REFERENCES wallet_reversal_rule_evaluations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_evaluation_context_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_evaluation_context_rule
        FOREIGN KEY (rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_evaluation_context_owner
        FOREIGN KEY (wallet_owner_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_context_reversal
ON wallet_reversal_rule_evaluation_context(reversal_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_context_rule
ON wallet_reversal_rule_evaluation_context(rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_context_owner
ON wallet_reversal_rule_evaluation_context(wallet_owner_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_context_kyc
ON wallet_reversal_rule_evaluation_context(kyc_verified);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_context_rule_active
ON wallet_reversal_rule_evaluation_context(rule_active);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_evaluation_context_captured
ON wallet_reversal_rule_evaluation_context(captured_at);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_rule_evaluation_context IS
'Immutable snapshot of the relevant wallet, rule, KYC, assignment, and approval context used during reversal rule evaluation.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.evaluation_id IS
'Rule evaluation associated with this context snapshot.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.reversal_id IS
'Wallet adjustment reversal being evaluated.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.rule_id IS
'Approval rule evaluated against the reversal.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.amount IS
'Amount considered during rule evaluation.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.currency_code IS
'Currency considered during rule evaluation.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.wallet_owner_id IS
'Wallet owner associated with the reversal being evaluated.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.kyc_status IS
'KYC status observed at evaluation time.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.kyc_verified IS
'Whether KYC was verified at evaluation time.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.admin_required IS
'Whether the evaluated rule required administrator approval.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.admin_requirement_satisfied IS
'Whether the administrator requirement was satisfied at evaluation time.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.assignment_required IS
'Whether an authorized user or role assignment was required.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.assignment_satisfied IS
'Whether the required assignment was satisfied at evaluation time.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.rule_active IS
'Whether the approval rule was active when evaluated.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.rule_priority IS
'Priority of the approval rule at evaluation time.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.approval_level IS
'Approval hierarchy level supplied by the evaluated rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.required_approvals IS
'Number of approvals required by the evaluated rule.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.context_snapshot IS
'Complete structured snapshot of additional evaluation inputs and context.';

COMMENT ON COLUMN wallet_reversal_rule_evaluation_context.captured_at IS
'Timestamp when the evaluation context was captured.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
