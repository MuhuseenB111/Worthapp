-- =========================================================
-- WORTHAPP
-- FIX FINDING ACTION EVIDENCE ACTIONS REVIEW FOREIGN KEY
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- Migration: 059
-- =========================================================

BEGIN;

-- =========================================================
-- REMOVE INCORRECT REVIEW FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions
DROP CONSTRAINT IF EXISTS
    fk_finding_action_evidence_actions_review;

-- =========================================================
-- ADD CORRECT REVIEW FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions

ADD CONSTRAINT
    fk_finding_action_evidence_actions_review

FOREIGN KEY (review_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verification_result_action_review_reviews(id)

ON DELETE CASCADE;

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
