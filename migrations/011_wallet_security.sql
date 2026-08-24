-- =========================================================
-- WORTHAPP
-- WALLET SECURITY & RISK EVENTS
-- Migration: 011
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET SECURITY EVENTS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    event_type VARCHAR(50) NOT NULL,

    severity VARCHAR(20) NOT NULL DEFAULT 'low'
        CHECK (
            severity IN (
                'low',
                'medium',
                'high',
                'critical'
            )
        ),

    status VARCHAR(30) NOT NULL DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'reviewing',
                'resolved',
                'blocked'
            )
        ),

    ip_address INET,

    user_agent TEXT,

    device_id VARCHAR(255),

    description TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    resolved_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_security_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_security_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_security_event_type_not_empty
        CHECK (
            LENGTH(TRIM(event_type)) > 0
        )
);

-- =========================================================
-- SECURITY EVENT INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_security_wallet_id
ON wallet_security_events(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_security_user_id
ON wallet_security_events(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_security_event_type
ON wallet_security_events(event_type);

CREATE INDEX IF NOT EXISTS
idx_wallet_security_severity
ON wallet_security_events(severity);

CREATE INDEX IF NOT EXISTS
idx_wallet_security_status
ON wallet_security_events(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_security_created_at
ON wallet_security_events(created_at);

-- =========================================================
-- WALLET SECURITY LOCKS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_security_locks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    is_locked BOOLEAN NOT NULL DEFAULT FALSE,

    lock_reason VARCHAR(100),

    locked_by VARCHAR(50),

    locked_at TIMESTAMPTZ,

    unlock_at TIMESTAMPTZ,

    failed_attempts INTEGER NOT NULL DEFAULT 0
        CHECK (
            failed_attempts >= 0
        ),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_security_locks_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_security_locks_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================================
-- SECURITY LOCK INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_security_locks_user_id
ON wallet_security_locks(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_security_locks_locked
ON wallet_security_locks(is_locked);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS
trg_wallet_security_events_updated_at
ON wallet_security_events;

CREATE TRIGGER
trg_wallet_security_events_updated_at
BEFORE UPDATE ON wallet_security_events
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS
trg_wallet_security_locks_updated_at
ON wallet_security_locks;

CREATE TRIGGER
trg_wallet_security_locks_updated_at
BEFORE UPDATE ON wallet_security_locks
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_security_events IS
'Security, fraud, risk and suspicious activity events associated with Worthapp wallets.';

COMMENT ON TABLE wallet_security_locks IS
'Wallet-level security locks used to temporarily or permanently restrict wallet operations.';

COMMENT ON COLUMN wallet_security_events.event_type IS
'Type of wallet security event, such as failed withdrawal, suspicious login or unusual activity.';

COMMENT ON COLUMN wallet_security_events.severity IS
'Risk severity assigned to the security event.';

COMMENT ON COLUMN wallet_security_locks.failed_attempts IS
'Number of failed security attempts associated with the wallet.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
