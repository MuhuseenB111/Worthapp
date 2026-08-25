-- =========================================================
-- WORTHAPP
-- FIX FINDING REVIEW FINDINGS ACTIONS RESULT FOREIGN KEY
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- Migration: 067
-- =========================================================

BEGIN;

-- =========================================================
-- REMOVE INCORRECT RESULT FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings_actions

DROP CONSTRAINT IF EXISTS
    fk_finding_review_findings_actions_result;

-- =========================================================
-- ADD CORRECT RESULT FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings_actions

ADD CONSTRAINT
    fk_finding_review_findings_actions_result

FOREIGN KEY (result_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verification_result_actions(id)

ON DELETE CASCADE;

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
