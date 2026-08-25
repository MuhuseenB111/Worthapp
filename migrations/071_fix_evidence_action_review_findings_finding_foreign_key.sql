-- =========================================================
-- WORTHAPP
-- FIX EVIDENCE ACTION REVIEW FINDINGS
-- FINDING FOREIGN KEY
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW FINDING
-- Migration: 071
-- =========================================================

BEGIN;

-- =========================================================
-- REMOVE INCORRECT FINDING FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings

DROP CONSTRAINT IF EXISTS
    fk_evidence_action_review_findings_finding;

-- =========================================================
-- ADD CORRECT FINDING FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings

ADD CONSTRAINT
    fk_evidence_action_review_findings_finding

FOREIGN KEY (finding_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings(id)

ON DELETE CASCADE;

-- =========================================================
-- COMMENT
-- =========================================================

COMMENT ON CONSTRAINT
    fk_evidence_action_review_findings_finding
ON
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings
IS
'Correct foreign key linking finding_id to the original finding action review finding record.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
