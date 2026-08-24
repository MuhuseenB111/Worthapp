-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL RULE ASSIGNMENTS
-- Migration: 030
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_rule_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    rule_id UUID NOT NULL,

    user_id UUID,

    role_name VARCHAR(80),

    assignment_type VARCHAR(20) NOT NULL DEFAULT 'user'
        CHECK (
            assignment_type IN (
                'user',
                'role'
            )
        ),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    assigned_by UUID,

    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    revoked_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    CONSTRAINT fk_reversal_rule_assignments_rule
        FOREIGN KEY (rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_rule_assignments_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reversal_rule_assignments_assigned_by
        FOREIGN KEY (assigned_by)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_reversal_rule_assignment_target_check
        CHECK (
            (
                assignment_type = 'user'
                AND user_id IS NOT NULL
                AND role_name IS NULL
            )
            OR
            (
                assignment_type = 'role'
                AND role_name IS NOT NULL
                AND user_id IS NULL
            )
        ),

    CONSTRAINT wallet_reversal_rule_assignment_status_check
        CHECK (
            (is_active = TRUE AND revoked_at IS NULL)
            OR
            (is_active = FALSE)
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_assignments_rule
ON wallet_reversal_approval_rule_assignments(rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_assignments_user
ON wallet_reversal_approval_rule_assignments(user_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_assignments_role
ON wallet_reversal_approval_rule_assignments(role_name);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_assignments_active
ON wallet_reversal_approval_rule_assignments(is_active);

CREATE INDEX IF NOT EXISTS
idx_reversal_rule_assignments_rule_active
ON wallet_reversal_approval_rule_assignments(rule_id, is_active);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_rule_assignments IS
'Users and roles authorized to participate in wallet reversal approval rules.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignments.rule_id IS
'Approval rule associated with this authorization assignment.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignments.user_id IS
'Specific user assigned to the approval rule when assignment_type is user.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignments.role_name IS
'Authorized role assigned to the approval rule when assignment_type is role.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignments.assignment_type IS
'Whether authorization is assigned to a specific user or a role.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignments.assigned_by IS
'User who created the authorization assignment.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignments.assigned_at IS
'Timestamp when the authorization assignment was created.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignments.revoked_at IS
'Timestamp when the authorization assignment was revoked.';

COMMENT ON COLUMN wallet_reversal_approval_rule_assignments.metadata IS
'Additional structured authorization information.';

COMMIT;
