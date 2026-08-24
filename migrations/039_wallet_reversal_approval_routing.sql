-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL ROUTING
-- Migration: 039
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL ROUTING
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_routing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reversal_id UUID NOT NULL,

    evaluation_id UUID,

    rule_id UUID,

    approval_id UUID,

    assignment_id UUID,

    route_type VARCHAR(20) NOT NULL DEFAULT 'user'
        CHECK (
            route_type IN (
                'user',
                'role',
                'admin',
                'manual'
            )
        ),

    target_user_id UUID,

    target_role_name VARCHAR(80),

    approval_level INTEGER NOT NULL DEFAULT 1
        CHECK (approval_level > 0),

    route_sequence INTEGER NOT NULL DEFAULT 1
        CHECK (route_sequence > 0),

    required_approvals INTEGER NOT NULL DEFAULT 1
        CHECK (required_approvals > 0),

    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'assigned',
                'accepted',
                'approved',
                'rejected',
                'skipped',
                'cancelled',
                'expired',
                'completed'
            )
        ),

    assigned_at TIMESTAMPTZ,

    responded_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    decision_reason TEXT,

    notes TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_approval_routing_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_routing_evaluation
        FOREIGN KEY (evaluation_id)
        REFERENCES wallet_reversal_rule_evaluations(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_reversal_approval_routing_rule
        FOREIGN KEY (rule_id)
        REFERENCES wallet_reversal_approval_rules(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_reversal_approval_routing_approval
        FOREIGN KEY (approval_id)
        REFERENCES wallet_reversal_approvals(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_reversal_approval_routing_assignment
        FOREIGN KEY (assignment_id)
        REFERENCES wallet_reversal_approval_rule_assignments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_reversal_approval_routing_user
        FOREIGN KEY (target_user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_reversal_approval_routing_target_check
        CHECK (
            (
                route_type = 'user'
                AND target_user_id IS NOT NULL
                AND target_role_name IS NULL
            )
            OR
            (
                route_type = 'role'
                AND target_role_name IS NOT NULL
                AND target_user_id IS NULL
            )
            OR
            (
                route_type IN ('admin', 'manual')
            )
        ),

    CONSTRAINT wallet_reversal_approval_routing_expiry_check
        CHECK (
            expires_at IS NULL
            OR expires_at > created_at
        ),

    CONSTRAINT wallet_reversal_approval_routing_response_check
        CHECK (
            responded_at IS NULL
            OR responded_at >= created_at
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_reversal
ON wallet_reversal_approval_routing(reversal_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_evaluation
ON wallet_reversal_approval_routing(evaluation_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_rule
ON wallet_reversal_approval_routing(rule_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_approval
ON wallet_reversal_approval_routing(approval_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_assignment
ON wallet_reversal_approval_routing(assignment_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_user
ON wallet_reversal_approval_routing(target_user_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_role
ON wallet_reversal_approval_routing(target_role_name);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_status
ON wallet_reversal_approval_routing(status);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_level
ON wallet_reversal_approval_routing(
    reversal_id,
    approval_level
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_sequence
ON wallet_reversal_approval_routing(
    reversal_id,
    route_sequence
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_pending
ON wallet_reversal_approval_routing(
    status,
    expires_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_routing IS
'Routes wallet reversal approval requests to authorized users, roles, administrators, or manual review channels.';

COMMENT ON COLUMN wallet_reversal_approval_routing.reversal_id IS
'Wallet adjustment reversal requiring approval routing.';

COMMENT ON COLUMN wallet_reversal_approval_routing.evaluation_id IS
'Rule evaluation that produced or influenced this approval route.';

COMMENT ON COLUMN wallet_reversal_approval_routing.rule_id IS
'Approval rule responsible for the routing decision.';

COMMENT ON COLUMN wallet_reversal_approval_routing.approval_id IS
'Approval request associated with this routing record.';

COMMENT ON COLUMN wallet_reversal_approval_routing.assignment_id IS
'Authorization assignment used to determine the approval target.';

COMMENT ON COLUMN wallet_reversal_approval_routing.route_type IS
'Type of approval destination: user, role, administrator, or manual review.';

COMMENT ON COLUMN wallet_reversal_approval_routing.target_user_id IS
'Specific user receiving the approval request when route_type is user.';

COMMENT ON COLUMN wallet_reversal_approval_routing.target_role_name IS
'Role receiving the approval request when route_type is role.';

COMMENT ON COLUMN wallet_reversal_approval_routing.approval_level IS
'Approval hierarchy level associated with this route.';

COMMENT ON COLUMN wallet_reversal_approval_routing.route_sequence IS
'Order in which this approval route should be processed.';

COMMENT ON COLUMN wallet_reversal_approval_routing.required_approvals IS
'Number of approvals required for this routing stage.';

COMMENT ON COLUMN wallet_reversal_approval_routing.status IS
'Current status of the approval routing record.';

COMMENT ON COLUMN wallet_reversal_approval_routing.assigned_at IS
'Timestamp when the approval route was assigned.';

COMMENT ON COLUMN wallet_reversal_approval_routing.responded_at IS
'Timestamp when the routed approval received a response.';

COMMENT ON COLUMN wallet_reversal_approval_routing.expires_at IS
'Timestamp after which the approval route expires.';

COMMENT ON COLUMN wallet_reversal_approval_routing.decision_reason IS
'Reason provided for the approval routing decision.';

COMMENT ON COLUMN wallet_reversal_approval_routing.notes IS
'Additional information associated with the approval route.';

COMMENT ON COLUMN wallet_reversal_approval_routing.metadata IS
'Additional structured routing information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
