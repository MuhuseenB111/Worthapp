-- =========================================================
-- WORTHAPP
-- WALLET ADDRESSES
-- Migration: 010
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET ADDRESSES
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    wallet_id UUID NOT NULL,

    user_id UUID NOT NULL,

    network VARCHAR(50) NOT NULL,

    asset_code VARCHAR(30) NOT NULL,

    address TEXT NOT NULL,

    address_label VARCHAR(100),

    address_type VARCHAR(30) NOT NULL DEFAULT 'external'
        CHECK (
            address_type IN (
                'internal',
                'external',
                'deposit',
                'withdrawal'
            )
        ),

    status VARCHAR(30) NOT NULL DEFAULT 'active'
        CHECK (
            status IN (
                'active',
                'inactive',
                'pending',
                'blocked'
            )
        ),

    is_verified BOOLEAN NOT NULL DEFAULT FALSE,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wallet_addresses_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_addresses_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT wallet_addresses_network_not_empty
        CHECK (
            LENGTH(TRIM(network)) > 0
        ),

    CONSTRAINT wallet_addresses_asset_not_empty
        CHECK (
            LENGTH(TRIM(asset_code)) > 0
        ),

    CONSTRAINT wallet_addresses_address_not_empty
        CHECK (
            LENGTH(TRIM(address)) > 0
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_wallet_addresses_wallet_id
ON wallet_addresses(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_addresses_user_id
ON wallet_addresses(user_id);

CREATE INDEX IF NOT EXISTS
idx_wallet_addresses_network
ON wallet_addresses(network);

CREATE INDEX IF NOT EXISTS
idx_wallet_addresses_asset
ON wallet_addresses(asset_code);

CREATE INDEX IF NOT EXISTS
idx_wallet_addresses_status
ON wallet_addresses(status);

CREATE INDEX IF NOT EXISTS
idx_wallet_addresses_verified
ON wallet_addresses(is_verified);

-- =========================================================
-- UNIQUE ADDRESS PER NETWORK
-- =========================================================

CREATE UNIQUE INDEX IF NOT EXISTS
idx_wallet_addresses_unique_network_address
ON wallet_addresses(
    network,
    address
);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================

DROP TRIGGER IF EXISTS
trg_wallet_addresses_updated_at
ON wallet_addresses;

CREATE TRIGGER
trg_wallet_addresses_updated_at
BEFORE UPDATE ON wallet_addresses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_addresses IS
'Blockchain and external wallet addresses associated with Worthapp wallets.';

COMMENT ON COLUMN wallet_addresses.network IS
'Blockchain network used by the wallet address.';

COMMENT ON COLUMN wallet_addresses.asset_code IS
'Asset or token associated with the address.';

COMMENT ON COLUMN wallet_addresses.address IS
'Public blockchain wallet address.';

COMMENT ON COLUMN wallet_addresses.is_verified IS
'Indicates whether the address has passed Worthapp verification.';

COMMENT ON COLUMN wallet_addresses.is_primary IS
'Indicates the primary address for the wallet and asset.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
