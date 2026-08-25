-- =========================================================
-- WORTHAPP
-- FIX FINDING ACTION EVIDENCE ACTION REVIEWS FOREIGN KEYS
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW FINDING ACTION
-- EVIDENCE ACTION REVIEWS
-- Migration: 062
-- =========================================================

BEGIN;

-- =========================================================
-- FIX RESULT FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews
DROP CONSTRAINT IF EXISTS
    fk_finding_action_evidence_action_reviews_result;

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews
ADD CONSTRAINT
    fk_finding_action_evidence_action_reviews_result
FOREIGN KEY (result_id)
REFERENCES
    wallet_reversal_approval_decision_evidence_verification_result_actions(id)
ON DELETE CASCADE;

-- =========================================================
-- FIX VERIFICATION FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews
DROP CONSTRAINT IF EXISTS
    fk_finding_action_evidence_action_reviews_verification;

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews
ADD CONSTRAINT
    fk_finding_action_evidence_action_reviews_verification
FOREIGN KEY (verification_id)
REFERENCES
    wallet_reversal_approval_decision_evidence_verifications(id)
ON DELETE CASCADE;

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON CONSTRAINT
    fk_finding_action_evidence_action_reviews_result
ON
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews
IS
'Correct foreign key linking result_id to the verification result action record.';

COMMENT ON CONSTRAINT
    fk_finding_action_evidence_action_reviews_verification
ON
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews
IS
'Correct foreign key linking verification_id to the evidence verification record.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
