-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL ROUTING ACTIONS
-- Migration: 040
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL ROUTING ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_routing_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    routing_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'assigned',
                'reassigned',
                'accepted',
                'approved',
                'rejected',
                'skipped',
                'cancelled',
                'expired',
                'completed',
                'overridden',
                'escalated'
            )
        ),

    previous_status VARCHAR(20),

    new_status VARCHAR(20),

    previous_target_user_id UUID,

    new_target_user_id UUID,

    previous_target_role_name VARCHAR(80),

    new_target_role_name VARCHAR(80),

    reason TEXT,

    notes TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_approval_routing_actions_routing
        FOREIGN KEY (routing_id)
        REFERENCES wallet_reversal_approval_routing(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_routing_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_routing_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reversal_approval_routing_actions_previous_user
        FOREIGN KEY (previous_target_user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reversal_approval_routing_actions_new_user
        FOREIGN KEY (new_target_user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_actions_routing
ON wallet_reversal_approval_routing_actions(routing_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_actions_reversal
ON wallet_reversal_approval_routing_actions(reversal_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_actions_actor
ON wallet_reversal_approval_routing_actions(actor_id);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_actions_type
ON wallet_reversal_approval_routing_actions(action_type);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_actions_created
ON wallet_reversal_approval_routing_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_actions_routing_created
ON wallet_reversal_approval_routing_actions(
    routing_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_routing_actions_reversal_created
ON wallet_reversal_approval_routing_actions(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_routing_actions IS
'Audit trail for actions performed while routing wallet reversal approvals.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.routing_id IS
'Approval routing record associated with this action.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.reversal_id IS
'Wallet adjustment reversal associated with the routing action.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.actor_id IS
'User or authorized system actor responsible for the routing action.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.action_type IS
'Type of action performed during the approval routing lifecycle.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.previous_status IS
'Routing status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.new_status IS
'Routing status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.previous_target_user_id IS
'Previous user target before reassignment, when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.new_target_user_id IS
'New user target after assignment or reassignment, when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.previous_target_role_name IS
'Previous role target before reassignment, when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.new_target_role_name IS
'New role target after assignment or reassignment, when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.reason IS
'Reason associated with the routing action.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.notes IS
'Additional information associated with the routing action.';

COMMENT ON COLUMN wallet_reversal_approval_routing_actions.metadata IS
'Additional structured routing audit information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
