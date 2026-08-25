-- =========================================================
-- WORTHAPP
-- FIX FINDING REVIEW FINDINGS ACTIONS
-- VERIFICATION FOREIGN KEY
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- Migration: 070
-- =========================================================

BEGIN;

-- =========================================================
-- REMOVE INCORRECT VERIFICATION FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings_actions

DROP CONSTRAINT IF EXISTS
    fk_finding_review_findings_actions_verification;

-- =========================================================
-- ADD CORRECT VERIFICATION FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings_actions

ADD CONSTRAINT
    fk_finding_review_findings_actions_verification

FOREIGN KEY (verification_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verifications(id)

ON DELETE CASCADE;

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
