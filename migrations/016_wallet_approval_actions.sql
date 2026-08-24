-- =========================================================
-- WORTHAPP
-- WALLET APPROVAL ACTIONS / AUDIT TRAIL
-- Migration: 016
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET APPROVAL ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_approval_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    approval_id UUID NOT NULL,

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

    CONSTRAINT fk_wallet_approval_actions_approval
        FOREIGN KEY (approval_id)
        REFERENCES wallet_approvals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_approval_actions_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_approval_actions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_approval_actions_action_not_empty
        CHECK (
            LENGTH(TRIM(action)) > 0
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_approval_actions_approval_id
ON wallet_approval_actions(approval_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_approval_actions_wallet_id
ON wallet_approval_actions(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_approval_actions_user_id
ON wallet_approval_actions(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_approval_actions_action
ON wallet_approval_actions(action);

CREATE INDEX IF NOT EXISTS
idx_wallet_approval_actions_created_at
ON wallet_approval_actions(created_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_approval_actions_ip
ON wallet_approval_actions(ip_address);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_approval_actions IS
'Audit trail for all actions performed on Worthapp wallet approvals.';

COMMENT ON COLUMN wallet_approval_actions.action IS
'Action performed on the approval request.';

COMMENT ON COLUMN wallet_approval_actions.previous_status IS
'Approval status before the action.';

COMMENT ON COLUMN wallet_approval_actions.new_status IS
'Approval status after the action.';

COMMENT ON COLUMN wallet_approval_actions.ip_address IS
'IP address associated with the approval action.';

COMMENT ON COLUMN wallet_approval_actions.user_agent IS
'Client user-agent associated with the approval action.';

COMMENT ON COLUMN wallet_approval_actions.device_id IS
'Application device identifier associated with the action.';

COMMENT ON COLUMN wallet_approval_actions.metadata IS
'Additional structured security and audit information.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
