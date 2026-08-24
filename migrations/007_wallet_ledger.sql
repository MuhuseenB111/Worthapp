-- =========================================================
-- WORTHAPP
-- WALLET TRANSACTION LEDGER
-- Migration: 007
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET TRANSACTIONS
-- =========================================================
--
-- This table records the business-level transaction.
--
-- Examples:
-- - deposit
-- - withdrawal
-- - transfer
-- - payment
-- - refund
-- - fee
-- - adjustment
--
-- IMPORTANT:
-- Transaction records should be treated as financial history.
-- Existing completed transactions should not be casually
-- deleted or modified.
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reference_id VARCHAR(100) NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    transaction_type VARCHAR(30) NOT NULL
        CHECK (
            transaction_type IN (
                'deposit',
                'withdrawal',
                'transfer',
                'payment',
                'refund',
                'fee',
                'adjustment'
            )
        ),

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'processing',
                'completed',
                'failed',
                'cancelled',
                'reversed'
            )
        ),

    currency_code VARCHAR(20) NOT NULL,

    amount NUMERIC(30, 12) NOT NULL,

    fee_amount NUMERIC(30, 12) NOT NULL DEFAULT 0,

    description TEXT,

    external_reference VARCHAR(150),

    idempotency_key VARCHAR(150),

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    completed_at TIMESTAMPTZ,

    CONSTRAINT fk_wallet_transactions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_transaction_amount_positive
        CHECK (amount > 0),

    CONSTRAINT wallet_transaction_fee_nonnegative
        CHECK (fee_amount >= 0),

    CONSTRAINT wallet_transaction_currency_not_empty
        CHECK (
            LENGTH(TRIM(currency_code)) > 0
        ),

    CONSTRAINT wallet_transaction_reference_not_empty
        CHECK (
            LENGTH(TRIM(reference_id)) > 0
        )
);

-- =========================================================
-- TRANSACTION INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_user_id
    ON wallet_transactions(user_id);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_status
    ON wallet_transactions(status);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_type
    ON wallet_transactions(transaction_type);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_currency
    ON wallet_transactions(currency_code);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_created_at
    ON wallet_transactions(created_at);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_external_reference
    ON wallet_transactions(external_reference);

-- =========================================================
-- IDEMPOTENCY
-- =========================================================
--
-- Prevents accidental duplicate financial requests.
-- =========================================================

CREATE UNIQUE INDEX IF NOT EXISTS
idx_wallet_transactions_idempotency
ON wallet_transactions(idempotency_key)
WHERE idempotency_key IS NOT NULL;

-- =========================================================
-- WALLET TRANSACTION ENTRIES
-- =========================================================
--
-- Double-entry foundation.
--
-- Every financial transaction can have one or more entries.
--
-- Examples:
--
-- Transfer:
--   Wallet A  -> debit
--   Wallet B  -> credit
--
-- Deposit:
--   System/settlement -> credit to user wallet
--
-- Withdrawal:
--   User wallet -> debit
--
-- This provides a stronger foundation for financial
-- reconciliation and auditing.
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_transaction_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    transaction_id UUID NOT NULL,

    wallet_id UUID NOT NULL,

    entry_type VARCHAR(20) NOT NULL
        CHECK (
            entry_type IN (
                'debit',
                'credit'
            )
        ),

    amount NUMERIC(30, 12) NOT NULL,

    currency_code VARCHAR(20) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_transaction_entries_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES wallet_transactions(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_transaction_entries_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallet_accounts(id)
        ON DELETE RESTRICT,

    CONSTRAINT transaction_entry_amount_positive
        CHECK (amount > 0),

    CONSTRAINT transaction_entry_currency_not_empty
        CHECK (
            LENGTH(TRIM(currency_code)) > 0
        )
);

-- =========================================================
-- TRANSACTION ENTRY INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_transaction_entries_transaction_id
ON wallet_transaction_entries(transaction_id);

CREATE INDEX IF NOT EXISTS
idx_transaction_entries_wallet_id
ON wallet_transaction_entries(wallet_id);

CREATE INDEX IF NOT EXISTS
idx_transaction_entries_entry_type
ON wallet_transaction_entries(entry_type);

CREATE INDEX IF NOT EXISTS
idx_transaction_entries_created_at
ON wallet_transaction_entries(created_at);

-- =========================================================
-- TRANSACTION STATUS HISTORY
-- =========================================================
--
-- Keeps a history whenever a transaction changes state.
--
-- Example:
--
-- pending
--    ↓
-- processing
--    ↓
-- completed
--
-- or
--
-- pending
--    ↓
-- failed
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_transaction_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    transaction_id UUID NOT NULL,

    previous_status VARCHAR(30),

    new_status VARCHAR(30) NOT NULL,

    reason TEXT,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_transaction_status_history_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES wallet_transactions(id)
        ON DELETE CASCADE
);

-- =========================================================
-- STATUS HISTORY INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_transaction_status_history_transaction_id
ON wallet_transaction_status_history(transaction_id);

CREATE INDEX IF NOT EXISTS
idx_transaction_status_history_created_at
ON wallet_transaction_status_history(created_at);

-- =========================================================
-- TRANSACTION VALIDATION
-- =========================================================

ALTER TABLE wallet_transactions
DROP CONSTRAINT IF EXISTS
wallet_transaction_completed_at_status_check;

ALTER TABLE wallet_transactions
ADD CONSTRAINT
wallet_transaction_completed_at_status_check
CHECK (
    status <> 'completed'
    OR completed_at IS NOT NULL
);

-- =========================================================
-- LEDGER IMMUTABILITY FOUNDATION
-- =========================================================
--
-- Completed financial entries should remain part of the
-- historical ledger.
--
-- Application-level authorization will enforce stronger
-- immutability rules later.
-- =========================================================

COMMENT ON TABLE wallet_transactions IS
'Financial transaction records for Worthapp wallets.';

COMMENT ON TABLE wallet_transaction_entries IS
'Double-entry ledger records associated with wallet transactions.';

COMMENT ON TABLE wallet_transaction_status_history IS
'Historical status changes for wallet transactions.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
