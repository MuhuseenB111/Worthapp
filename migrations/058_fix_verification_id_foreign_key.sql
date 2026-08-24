-- =========================================================
-- WORTHAPP
-- FIX VERIFICATION ID FOREIGN KEY
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- Migration: 058
-- =========================================================

BEGIN;

-- =========================================================
-- REMOVE INCORRECT FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence
DROP CONSTRAINT IF EXISTS
    fk_finding_action_evidence_verification;

-- =========================================================
-- ADD CORRECT FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence

ADD CONSTRAINT
    fk_finding_action_evidence_verification

FOREIGN KEY (verification_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verifications(id)

ON DELETE CASCADE;

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
