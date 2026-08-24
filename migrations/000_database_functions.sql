-- =========================================================
-- WORTHAPP
-- DATABASE CORE FUNCTIONS
-- Migration: 000
-- =========================================================

BEGIN;

-- =========================================================
-- UPDATED_AT FUNCTION
-- =========================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();

    RETURN NEW;
END;
$$;

-- =========================================================
-- FUNCTION COMMENT
-- =========================================================

COMMENT ON FUNCTION set_updated_at() IS
'Automatically updates updated_at timestamp before row updates.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
