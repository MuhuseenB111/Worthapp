-- =========================================================
-- WORTHAPP
-- WALLET HOLD ACTIONS / AUDIT TRAIL
-- Migration: 018
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET HOLD ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_hold_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    hold_id UUID NOT NULL,

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    action VARCHAR(40) NOT NULL,

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    reason VARCHAR(255),

    ip_address INET,

    user_agent TEXT,

    device_id VARCHAR(255),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_hold_actions_hold
        FOREIGN KEY (hold_id)
        REFERENCES wallet_holds(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_hold_actions_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_hold_actions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_hold_actions_action_not_empty
        CHECK (
            LENGTH(TRIM(action)) > 0
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_hold_actions_hold_id
ON wallet_hold_actions(hold_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_hold_actions_wallet_id
ON wallet_hold_actions(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_hold_actions_user_id
ON wallet_hold_actions(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_hold_actions_action
ON wallet_hold_actions(action);

CREATE INDEX IF NOT EXISTS
idx_wallet_hold_actions_created_at
ON wallet_hold_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_hold_actions_ip
ON wallet_hold_actions(ip_address);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_hold_actions IS
'Audit trail for actions performed on Worthapp wallet security holds.';

COMMENT ON COLUMN wallet_hold_actions.action IS
'Action performed on the wallet hold.';

COMMENT ON COLUMN wallet_hold_actions.previous_status IS
'Wallet hold status before the action.';

COMMENT ON COLUMN wallet_hold_actions.new_status IS
'Wallet hold status after the action.';

COMMENT ON COLUMN wallet_hold_actions.ip_address IS
'IP address associated with the action.';

COMMENT ON COLUMN wallet_hold_actions.user_agent IS
'Client user-agent associated with the action.';

COMMENT ON COLUMN wallet_hold_actions.device_id IS
'Application device identifier associated with the action.';

COMMENT ON COLUMN wallet_hold_actions.metadata IS
'Additional structured security and audit information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
