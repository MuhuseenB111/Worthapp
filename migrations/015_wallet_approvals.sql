-- =========================================================
-- WORTHAPP
-- WALLET APPROVALS
-- Migration: 015
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET APPROVALS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    withdrawal_id UUID,

    transfer_id UUID,

    approval_type VARCHAR(40) NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'approved',
                'rejected',
                'expired',
                'cancelled'
            )
        ),

    required_level INTEGER NOT NULL DEFAULT 1
        CHECK (
            required_level > 0
        ),

    approved_by UUID,

    rejection_reason VARCHAR(255),

    expires_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_approvals_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_approvals_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_approvals_approver
        FOREIGN KEY (approved_by)
        REFERENCES users(id)
        ON DELETE SET NULL,

    CONSTRAINT wallet_approvals_type_not_empty
        CHECK (
            LENGTH(TRIM(approval_type)) > 0
        ),

    CONSTRAINT wallet_approvals_target_check
        CHECK (
            withdrawal_id IS NOT NULL
            OR transfer_id IS NOT NULL
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_approvals_wallet_id
ON wallet_approvals(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_approvals_user_id
ON wallet_approvals(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_approvals_withdrawal_id
ON wallet_approvals(withdrawal_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_approvals_transfer_id
ON wallet_approvals(transfer_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_approvals_status
ON wallet_approvals(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_approvals_type
ON wallet_approvals(approval_type);

CREATE INDEX IF NOT EXISTS
idx_wallet_approvals_created_at
ON wallet_approvals(created_at);

CREATE INDEX IF NOT EXISTS
idx_wallet_approvals_expires_at
ON wallet_approvals(expires_at);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS
trg_wallet_approvals_updated_at
ON wallet_approvals;

CREATE TRIGGER
trg_wallet_approvals_updated_at
BEFORE UPDATE ON wallet_approvals
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_approvals IS
'Approval workflow for sensitive Worthapp wallet operations.';

COMMENT ON COLUMN wallet_approvals.approval_type IS
'Type of approval, such as withdrawal, transfer or security review.';

COMMENT ON COLUMN wallet_approvals.required_level IS
'Approval level required before the wallet operation can proceed.';

COMMENT ON COLUMN wallet_approvals.approved_by IS
'User or administrator who approved the wallet operation.';

COMMENT ON COLUMN wallet_approvals.metadata IS
'Additional structured information related to the approval request.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
