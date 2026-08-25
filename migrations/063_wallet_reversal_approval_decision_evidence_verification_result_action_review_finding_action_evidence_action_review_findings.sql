-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW FINDING
-- EVIDENCE ACTION REVIEW FINDINGS
-- Migration: 063
-- =========================================================

BEGIN;

-- =========================================================
-- FINDING ACTION EVIDENCE ACTION REVIEW FINDINGS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    evidence_action_review_id UUID NOT NULL,

    finding_action_evidence_action_id UUID NOT NULL,

    finding_action_evidence_id UUID NOT NULL,

    finding_action_id UUID NOT NULL,

    finding_id UUID NOT NULL,

    review_id UUID NOT NULL,

    review_action_id UUID NOT NULL,

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
                'inconsistency',
                'missing_evidence',
                'insufficient_evidence',
                'contradiction',
                'verification_failure',
                'verification_mismatch',
                'data_error',
                'process_error',
                'policy_violation',
                'risk',
                'fraud_indicator',
                'compliance_issue',
                'technical_issue',
                'documentation_issue',
                'other'
            )
        ),

    severity VARCHAR(20) NOT NULL DEFAULT 'medium'
        CHECK (
            severity IN (
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
                'evidence_requested',
                'verification_requested',
                'correction_requested',
                'resolved',
                'dismissed',
                'escalated',
                'reopened',
                'closed',
                'cancelled'
            )
        ),

    title VARCHAR(255) NOT NULL,

    description TEXT NOT NULL,

    decision VARCHAR(30)
        CHECK (
            decision IS NULL
            OR decision IN (
                'approve',
                'reject',
                'hold',
                'correct',
                'escalate',
                'dismiss',
                'resolve'
            )
        ),

    reason TEXT,

    resolution TEXT,

    resolution_notes TEXT,

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR (
                confidence_score >= 0
                AND confidence_score <= 100
            )
        ),

    findings_data JSONB,

    previous_state JSONB,

    current_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    identified_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    resolved_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_evidence_action_review_findings_evidence_action_review
        FOREIGN KEY (evidence_action_review_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_reviews(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_evidence_action
        FOREIGN KEY (finding_action_evidence_action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_evidence
        FOREIGN KEY (finding_action_evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_finding_action
        FOREIGN KEY (finding_action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_finding
        FOREIGN KEY (finding_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_review
        FOREIGN KEY (review_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_reviews(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_review_action
        FOREIGN KEY (review_action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_action
        FOREIGN KEY (action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_result
        FOREIGN KEY (result_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_source_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_action_review_findings_reviewer
        FOREIGN KEY (reviewer_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_review
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    evidence_action_review_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_evidence_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    finding_action_evidence_action_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    finding_action_evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_finding_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    finding_action_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_finding
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    finding_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_review_id
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    review_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_review_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    review_action_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    action_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_result
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    result_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_verification
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_source_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_decision
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_workflow
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_reversal
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_reviewer
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    reviewer_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_type
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    finding_type
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_severity
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    severity
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    status
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_decision_type
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    decision
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_identified
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    identified_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_resolved
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    resolved_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_updated
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    updated_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_review_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    evidence_action_review_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_status_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    status,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_severity_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    severity,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_action_review_findings_reversal_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings IS
'Structured findings identified during reviews of lifecycle actions performed on evidence associations attached to wallet reversal approval review findings.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.evidence_action_review_id IS
'Evidence action review record in which the finding was identified.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.finding_action_evidence_action_id IS
'Evidence action associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.finding_action_evidence_id IS
'Evidence association associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.finding_action_id IS
'Finding action associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.finding_id IS
'Original review finding associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.review_id IS
'Parent review associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.review_action_id IS
'Review action associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.action_id IS
'Original verification result action associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.result_id IS
'Verification result action associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.verification_id IS
'Evidence verification record associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.evidence_id IS
'Source evidence associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.decision_id IS
'Approval decision associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.workflow_id IS
'Approval workflow associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.reversal_id IS
'Wallet adjustment reversal associated with the finding review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.reviewer_id IS
'Authorized reviewer responsible for identifying or reviewing the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.finding_type IS
'Classification of the finding identified during the evidence action review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.severity IS
'Severity assigned to the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.status IS
'Current lifecycle status of the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.title IS
'Short human-readable title of the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.description IS
'Detailed description of the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.decision IS
'Decision associated with the finding when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.reason IS
'Reason supporting the finding or decision.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.resolution IS
'Resolution applied to the finding when resolved.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.resolution_notes IS
'Additional information about how the finding was resolved.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.confidence_score IS
'Confidence score associated with the finding assessment.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.findings_data IS
'Additional structured finding information.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.previous_state IS
'Structured finding state before the latest update.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.current_state IS
'Current structured finding state.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.metadata IS
'Additional structured finding metadata.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.identified_at IS
'Timestamp when the finding was identified.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.resolved_at IS
'Timestamp when the finding was resolved.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.created_at IS
'Timestamp when the finding record was created.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_action_review_findings.updated_at IS
'Timestamp when the finding record was last updated.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
