-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL RULES
-- Migration: 028
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    rule_name VARCHAR(100) NOT NULL UNIQUE,

    description TEXT,

    approval_level INTEGER NOT NULL DEFAULT 1
        CHECK (approval_level > 0),

    minimum_amount NUMERIC(30, 10)
        CHECK (minimum_amount IS NULL OR minimum_amount >= 0),

    maximum_amount NUMERIC(30, 10)
        CHECK (maximum_amount IS NULL OR maximum_amount >= 0),

    currency_code VARCHAR(20),

    required_approvals INTEGER NOT NULL DEFAULT 1
        CHECK (required_approvals > 0),

    requires_admin BOOLEAN NOT NULL DEFAULT TRUE,

    requires_kyc BOOLEAN NOT NULL DEFAULT TRUE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    priority INTEGER NOT NULL DEFAULT 100
        CHECK (priority >= 0),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT wallet_reversal_rule_amount_range_check
        CHECK (
            maximum_amount IS NULL
            OR minimum_amount IS NULL
            OR maximum_amount >= minimum_amount
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_rules_active
ON wallet_reversal_approval_rules(is_active);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_rules_level
ON wallet_reversal_approval_rules(approval_level);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_rules_priority
ON wallet_reversal_approval_rules(priority);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_rules_currency
ON wallet_reversal_approval_rules(currency_code);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_rules_amount_range
ON wallet_reversal_approval_rules(minimum_amount, maximum_amount);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_rules IS
'Configurable approval rules controlling wallet reversal authorization.';

COMMENT ON COLUMN wallet_reversal_approval_rules.rule_name IS
'Unique name identifying the approval rule.';

COMMENT ON COLUMN wallet_reversal_approval_rules.approval_level IS
'Approval hierarchy level associated with the rule.';

COMMENT ON COLUMN wallet_reversal_approval_rules.minimum_amount IS
'Minimum reversal amount to which the rule applies.';

COMMENT ON COLUMN wallet_reversal_approval_rules.maximum_amount IS
'Maximum reversal amount to which the rule applies.';

COMMENT ON COLUMN wallet_reversal_approval_rules.required_approvals IS
'Number of approvals required before a reversal can proceed.';

COMMENT ON COLUMN wallet_reversal_approval_rules.requires_admin IS
'Whether an administrator approval is required.';

COMMENT ON COLUMN wallet_reversal_approval_rules.requires_kyc IS
'Whether the wallet owner must satisfy KYC requirements.';

COMMENT ON COLUMN wallet_reversal_approval_rules.priority IS
'Rule evaluation priority; lower values are evaluated first.';

COMMENT ON COLUMN wallet_reversal_approval_rules.metadata IS
'Additional structured configuration for the rule.';

COMMIT;
