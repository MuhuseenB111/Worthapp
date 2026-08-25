-- =========================================================
-- WORTHAPP
-- FIX FINDING REVIEW FINDINGS ACTIONS FOREIGN KEYS
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- Migration: 066
-- =========================================================

BEGIN;

-- =========================================================
-- FIX RESULT FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings_actions

DROP CONSTRAINT IF EXISTS
    fk_finding_review_findings_actions_result;

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings_actions

ADD CONSTRAINT
    fk_finding_review_findings_actions_result

FOREIGN KEY (result_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verification_result_actions(id)

ON DELETE CASCADE;

-- =========================================================
-- FIX VERIFICATION FOREIGN KEY
-- =========================================================

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings_actions

DROP CONSTRAINT IF EXISTS
    fk_finding_review_findings_actions_verification;

ALTER TABLE
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_review_findings_actions

ADD CONSTRAINT
    fk_finding_review_findings_actions_verification

FOREIGN KEY (verification_id)

REFERENCES
    wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(id)

ON DELETE CASCADE;

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
