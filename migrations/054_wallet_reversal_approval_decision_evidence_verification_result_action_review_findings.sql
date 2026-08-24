-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW FINDINGS
-- Migration: 054
-- =========================================================

BEGIN;

-- =========================================================
-- VERIFICATION RESULT ACTION REVIEW FINDINGS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_result_action_review_findings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    review_id UUID NOT NULL,

    action_id UUID NOT NULL,

    result_id UUID NOT NULL,

    verification_id UUID NOT NULL,

    evidence_id UUID NOT NULL,

    decision_id UUID NOT NULL,

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    reviewer_id UUID,

    finding_type VARCHAR(40) NOT NULL
        CHECK (
            finding_type IN (
                'evidence_valid',
                'evidence_invalid',
                'evidence_missing',
                'evidence_incomplete',
                'evidence_mismatch',
                'verification_passed',
                'verification_failed',
                'verification_uncertain',
                'result_valid',
                'result_invalid',
                'result_incomplete',
                'policy_violation',
                'risk_detected',
                'fraud_indicator',
                'compliance_issue',
                'data_inconsistency',
                'manual_review_required',
                'other'
            )
        ),

    severity VARCHAR(20) NOT NULL DEFAULT 'medium'
        CHECK (
            severity IN (
                'info',
                'low',
                'medium',
                'high',
                'critical'
            )
        ),

    status VARCHAR(30) NOT NULL DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'acknowledged',
                'investigating',
                'resolved',
                'dismissed',
                'escalated'
            )
        ),

    title VARCHAR(255) NOT NULL,

    description TEXT,

    expected_value TEXT,

    actual_value TEXT,

    recommended_action TEXT,

    resolution TEXT,

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR (
                confidence_score >= 0
                AND confidence_score <= 100
            )
        ),

    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    resolved_at TIMESTAMPTZ,

    previous_state JSONB,

    current_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_review_findings_review
        FOREIGN KEY (review_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_reviews(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_findings_action
        FOREIGN KEY (action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_findings_result
        FOREIGN KEY (result_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_results(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_findings_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_findings_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_findings_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_findings_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_findings_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_findings_reviewer
        FOREIGN KEY (reviewer_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_review_findings_review
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    review_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    action_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_result
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    result_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_verification
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_decision
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_workflow
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_reversal
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_reviewer
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    reviewer_id
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_type
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    finding_type
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_severity
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    severity
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    status
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_detected
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    detected_at
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_resolved
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    resolved_at
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_review_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    review_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_result_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    result_id,
    status
);

CREATE INDEX IF NOT EXISTS
idx_review_findings_severity_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(
    severity,
    status
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_result_action_review_findings IS
'Structured findings identified during reviews of wallet reversal approval evidence verification result actions.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.review_id IS
'Review record in which the finding was identified.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.action_id IS
'Verification result action associated with the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.result_id IS
'Verification result associated with the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.verification_id IS
'Evidence verification associated with the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.evidence_id IS
'Evidence associated with the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.decision_id IS
'Approval decision associated with the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.workflow_id IS
'Approval workflow associated with the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.reversal_id IS
'Wallet adjustment reversal associated with the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.reviewer_id IS
'Authorized reviewer responsible for identifying or resolving the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.finding_type IS
'Classification of the finding identified during the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.severity IS
'Severity level assigned to the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.status IS
'Current lifecycle status of the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.title IS
'Short descriptive title of the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.description IS
'Detailed explanation of the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.expected_value IS
'Expected value or condition used when evaluating the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.actual_value IS
'Actual value or condition observed during the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.recommended_action IS
'Recommended action for resolving or addressing the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.resolution IS
'Resolution applied to the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.confidence_score IS
'Confidence score associated with the identified finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.detected_at IS
'Timestamp when the finding was detected.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.resolved_at IS
'Timestamp when the finding was resolved.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.previous_state IS
'Structured finding state before the latest update.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.current_state IS
'Current structured finding state.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.metadata IS
'Additional structured finding metadata.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.created_at IS
'Timestamp when the finding record was created.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_findings.updated_at IS
'Timestamp when the finding record was last updated.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
