-- =========================================================
-- WORTHAPP
-- FIX FINDING ACTION EVIDENCE ACTION REVIEWS
-- VERIFICATION FOREIGN KEY
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- Migration: 069
-- =========================================================

BEGIN;

-- =========================================================
-- REMOVE INCORRECT VERIFICATION FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews

DROP CONSTRAINT IF EXISTS
    fk_finding_action_evidence_action_reviews_verification;

-- =========================================================
-- ADD CORRECT VERIFICATION FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews

ADD CONSTRAINT
    fk_finding_action_evidence_action_reviews_verification

FOREIGN KEY (verification_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verifications(id)

ON DELETE CASCADE;

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
