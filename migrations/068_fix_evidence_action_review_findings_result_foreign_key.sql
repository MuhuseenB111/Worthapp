-- =========================================================
-- WORTHAPP
-- FIX EVIDENCE ACTION REVIEW FINDINGS RESULT FOREIGN KEY
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW FINDING
-- EVIDENCE ACTION REVIEW FINDINGS
-- Migration: 068
-- =========================================================

BEGIN;

-- =========================================================
-- REMOVE INCORRECT RESULT FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings

DROP CONSTRAINT IF EXISTS
    fk_evidence_action_review_findings_result;

-- =========================================================
-- ADD CORRECT RESULT FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings

ADD CONSTRAINT
    fk_evidence_action_review_findings_result

FOREIGN KEY (result_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verification_result_actions(id)

ON DELETE CASCADE;

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
