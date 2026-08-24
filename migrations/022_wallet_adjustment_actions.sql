-- =========================================================
-- WORTHAPP
-- WALLET RECONCILIATION ADJUSTMENT ACTIONS
-- Migration: 022
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET ADJUSTMENT ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_adjustment_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    adjustment_id UUID NOT NULL,

    action_type VARCHAR(40) NOT NULL,

    action_status VARCHAR(30) NOT NULL DEFAULT 'completed'
        CHECK (
            action_status IN (
                'pending',
                'completed',
                'failed',
                'cancelled'
            )
        ),

    performed_by UUID,

    reason TEXT,

    notes TEXT,

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    ip_address INET,

    user_agent TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_adjustment_actions_adjustment
        FOREIGN KEY (adjustment_id)
        REFERENCES wallet_reconciliation_adjustments(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_adjustment_actions_user
        FOREIGN KEY (performed_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_adjustment_actions_type_not_empty
        CHECK (
            LENGTH(TRIM(action_type)) > 0
        ),

    CONSTRAINT wallet_adjustment_actions_status_transition
        CHECK (
            previous_status IS NULL
            OR new_status IS NULL
            OR previous_status <> new_status
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_actions_adjustment
ON wallet_adjustment_actions(adjustment_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_actions_type
ON wallet_adjustment_actions(action_type);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_actions_status
ON wallet_adjustment_actions(action_status);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_actions_performed_by
ON wallet_adjustment_actions(performed_by);

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_actions_performed_at
ON wallet_adjustment_actions(performed_at);

-- =========================================================
-- ACTION TYPE INDEX
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_adjustment_actions_adjustment_type
ON wallet_adjustment_actions(adjustment_id, action_type);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_adjustment_actions IS
'Immutable audit trail for wallet reconciliation adjustment actions.';

COMMENT ON COLUMN wallet_adjustment_actions.adjustment_id IS
'Wallet reconciliation adjustment associated with this action.';

COMMENT ON COLUMN wallet_adjustment_actions.action_type IS
'Action performed on the adjustment.';

COMMENT ON COLUMN wallet_adjustment_actions.action_status IS
'Execution status of the action.';

COMMENT ON COLUMN wallet_adjustment_actions.performed_by IS
'User or administrator who performed the action.';

COMMENT ON COLUMN wallet_adjustment_actions.previous_status IS
'Adjustment status before the action.';

COMMENT ON COLUMN wallet_adjustment_actions.new_status IS
'Adjustment status after the action.';

COMMENT ON COLUMN wallet_adjustment_actions.ip_address IS
'IP address associated with the action when available.';

COMMENT ON COLUMN wallet_adjustment_actions.user_agent IS
'Client user-agent associated with the action when available.';

COMMENT ON COLUMN wallet_adjustment_actions.metadata IS
'Additional audit information associated with the action.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
