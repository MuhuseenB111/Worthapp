-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL ACTIONS
-- Migration: 025
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reversal_id UUID NOT NULL,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'requested',
                'reviewed',
                'approved',
                'rejected',
                'processing_started',
                'completed',
                'failed',
                'cancelled',
                'reopened'
            )
        ),

    actor_id UUID NOT NULL,

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    reason TEXT,

    notes TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_reversal_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_reversal_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_reversal_actions_reason_valid
        CHECK (
            reason IS NULL
            OR LENGTH(TRIM(reason)) > 0
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_actions_reversal
ON wallet_reversal_actions(reversal_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_actions_actor
ON wallet_reversal_actions(actor_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_actions_type
ON wallet_reversal_actions(action_type);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_actions_created_at
ON wallet_reversal_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_reversal_actions_reversal_created
ON wallet_reversal_actions(reversal_id, created_at);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_actions IS
'Immutable audit trail for actions performed on wallet adjustment reversals.';

COMMENT ON COLUMN wallet_reversal_actions.reversal_id IS
'Wallet adjustment reversal associated with this action.';

COMMENT ON COLUMN wallet_reversal_actions.action_type IS
'Type of action performed on the reversal.';

COMMENT ON COLUMN wallet_reversal_actions.actor_id IS
'User or authorized system actor that performed the action.';

COMMENT ON COLUMN wallet_reversal_actions.previous_status IS
'Status of the reversal before the action.';

COMMENT ON COLUMN wallet_reversal_actions.new_status IS
'Status of the reversal after the action.';

COMMENT ON COLUMN wallet_reversal_actions.reason IS
'Reason associated with the action when applicable.';

COMMENT ON COLUMN wallet_reversal_actions.notes IS
'Additional human-readable information about the action.';

COMMENT ON COLUMN wallet_reversal_actions.metadata IS
'Additional structured audit information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
