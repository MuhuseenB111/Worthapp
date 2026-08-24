-- =========================================================
-- WORTHAPP
-- DIGITAL WALLET FOUNDATION
-- Migration: 006
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET ACCOUNTS
-- =========================================================
--
-- Each user can have one or more wallets.
--
-- Examples:
-- - Main wallet
-- - Fiat wallet
-- - Crypto wallet
-- - Business wallet
--
-- Financial balances should be handled carefully by the
-- application/service layer.
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    wallet_type VARCHAR(30) NOT NULL DEFAULT 'personal'
        CHECK (
            wallet_type IN (
                'personal',
                'business',
                'savings',
                'escrow'
            )
        ),

    wallet_name VARCHAR(100) NOT NULL DEFAULT 'Main Wallet',

    currency_code VARCHAR(20) NOT NULL,

    network VARCHAR(50),

    address TEXT,

    address_reference TEXT,

    status VARCHAR(30) NOT NULL DEFAULT 'active'
        CHECK (
            status IN (
                'active',
                'frozen',
                'suspended',
                'closed'
            )
        ),

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_accounts_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================================
-- WALLET INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_wallet_accounts_user_id
    ON wallet_accounts(user_id);

CREATE INDEX IF NOT EXISTS idx_wallet_accounts_status
    ON wallet_accounts(status);

CREATE INDEX IF NOT EXISTS idx_wallet_accounts_currency
    ON wallet_accounts(currency_code);

CREATE INDEX IF NOT EXISTS idx_wallet_accounts_network
    ON wallet_accounts(network);

CREATE INDEX IF NOT EXISTS idx_wallet_accounts_primary
    ON wallet_accounts(is_primary);

CREATE INDEX IF NOT EXISTS idx_wallet_accounts_created_at
    ON wallet_accounts(created_at);

-- =========================================================
-- WALLET UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_wallet_accounts_updated_at
ON wallet_accounts;

CREATE TRIGGER trg_wallet_accounts_updated_at
BEFORE UPDATE ON wallet_accounts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- WALLET SECURITY
-- =========================================================
--
-- Wallet addresses are public blockchain information in
-- many systems, but private keys/seeds MUST NEVER be stored
-- in this table.
-- =========================================================

ALTER TABLE wallet_accounts
DROP CONSTRAINT IF EXISTS wallet_currency_not_empty;

ALTER TABLE wallet_accounts
ADD CONSTRAINT wallet_currency_not_empty
CHECK (
    LENGTH(TRIM(currency_code)) > 0
);

-- =========================================================
-- WALLET ADDRESS VALIDATION
-- =========================================================

ALTER TABLE wallet_accounts
DROP CONSTRAINT IF EXISTS wallet_address_reference_not_empty;

ALTER TABLE wallet_accounts
ADD CONSTRAINT wallet_address_reference_not_empty
CHECK (
    address_reference IS NULL
    OR LENGTH(TRIM(address_reference)) > 0
);

-- =========================================================
-- WALLET PRIMARY ACCOUNT RULE
-- =========================================================
--
-- A user can have only one primary wallet for the same
-- wallet type and currency.
-- =========================================================

CREATE UNIQUE INDEX IF NOT EXISTS
idx_wallet_primary_unique
ON wallet_accounts (
    user_id,
    wallet_type,
    currency_code
)
WHERE is_primary = TRUE;

-- =========================================================
-- WALLET BALANCE SNAPSHOTS
-- =========================================================
--
-- This table is NOT the authoritative transaction ledger.
--
-- It provides a safe place for current/derived balances.
-- The transaction ledger will be introduced separately.
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_balances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL UNIQUE,

    available_balance NUMERIC(30, 12) NOT NULL DEFAULT 0,

    pending_balance NUMERIC(30, 12) NOT NULL DEFAULT 0,

    locked_balance NUMERIC(30, 12) NOT NULL DEFAULT 0,

    last_calculated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_balances_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallet_accounts(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_available_balance_nonnegative
        CHECK (available_balance >= 0),

    CONSTRAINT wallet_pending_balance_nonnegative
        CHECK (pending_balance >= 0),

    CONSTRAINT wallet_locked_balance_nonnegative
        CHECK (locked_balance >= 0)
);

-- =========================================================
-- WALLET BALANCE INDEX
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_wallet_balances_wallet_id
    ON wallet_balances(wallet_id);

CREATE INDEX IF NOT EXISTS idx_wallet_balances_updated_at
    ON wallet_balances(updated_at);

-- =========================================================
-- WALLET BALANCE UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS trg_wallet_balances_updated_at
ON wallet_balances;

CREATE TRIGGER trg_wallet_balances_updated_at
BEFORE UPDATE ON wallet_balances
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- WALLET ACTIVITY
-- =========================================================
--
-- Records important wallet-level actions.
--
-- Examples:
-- wallet_created
-- wallet_connected
-- wallet_frozen
-- wallet_unfrozen
-- wallet_closed
-- wallet_address_updated
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    event_type VARCHAR(100) NOT NULL,

    ip_address INET,

    user_agent TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_events_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallet_accounts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_events_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================================
-- WALLET EVENT INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_wallet_events_wallet_id
    ON wallet_events(wallet_id);

CREATE INDEX IF NOT EXISTS idx_wallet_events_user_id
    ON wallet_events(user_id);

CREATE INDEX IF NOT EXISTS idx_wallet_events_event_type
    ON wallet_events(event_type);

CREATE INDEX IF NOT EXISTS idx_wallet_events_created_at
    ON wallet_events(created_at);

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
