-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULTS
-- Migration: 050
-- =========================================================

BEGIN;

-- =========================================================
-- EVIDENCE VERIFICATION RESULTS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    verification_id UUID NOT NULL,

    evidence_id UUID NOT NULL,

    decision_id UUID NOT NULL,

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    action_id UUID,

    result_type VARCHAR(40) NOT NULL
        CHECK (
            result_type IN (
                'document',
                'identity',
                'source',
                'integrity',
                'authenticity',
                'consistency',
                'completeness',
                'compliance',
                'manual_review'
            )
        ),

    result_status VARCHAR(30) NOT NULL
        CHECK (
            result_status IN (
                'passed',
                'failed',
                'warning',
                'inconclusive',
                'not_checked'
            )
        ),

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR (
                confidence_score >= 0
                AND confidence_score <= 100
            )
        ),

    reviewer_id UUID,

    reason TEXT,

    notes TEXT,

    reference_data JSONB,

    previous_result JSONB,

    result_data JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_evidence_verification_results_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_results_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_results_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_results_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_results_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_results_action
        FOREIGN KEY (action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_actions(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_evidence_verification_results_reviewer
        FOREIGN KEY (reviewer_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_verification
ON wallet_reversal_approval_decision_evidence_verification_results(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_evidence
ON wallet_reversal_approval_decision_evidence_verification_results(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_decision
ON wallet_reversal_approval_decision_evidence_verification_results(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_workflow
ON wallet_reversal_approval_decision_evidence_verification_results(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_reversal
ON wallet_reversal_approval_decision_evidence_verification_results(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_action
ON wallet_reversal_approval_decision_evidence_verification_results(
    action_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_reviewer
ON wallet_reversal_approval_decision_evidence_verification_results(
    reviewer_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_type
ON wallet_reversal_approval_decision_evidence_verification_results(
    result_type
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_status
ON wallet_reversal_approval_decision_evidence_verification_results(
    result_status
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_created
ON wallet_reversal_approval_decision_evidence_verification_results(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_verification_created
ON wallet_reversal_approval_decision_evidence_verification_results(
    verification_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_results_evidence_type
ON wallet_reversal_approval_decision_evidence_verification_results(
    evidence_id,
    result_type
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_results IS
'Individual verification results generated while validating evidence associated with wallet reversal approval decisions.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.verification_id IS
'Evidence verification record associated with this result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.evidence_id IS
'Evidence record evaluated by the verification process.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.decision_id IS
'Approval decision associated with the verification result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.workflow_id IS
'Approval workflow associated with the verification result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.reversal_id IS
'Wallet adjustment reversal associated with the verification result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.action_id IS
'Specific verification action that produced or recorded the result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.result_type IS
'Category of verification performed on the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.result_status IS
'Outcome of the verification check.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.confidence_score IS
'Optional confidence score from 0 to 100 associated with the verification result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.reviewer_id IS
'Authorized reviewer responsible for the verification result when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.reason IS
'Reason explaining the verification result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.notes IS
'Additional information about the verification result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.reference_data IS
'Structured references used during the verification process.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.previous_result IS
'Previous verification result when a result is being updated or re-evaluated.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.result_data IS
'Structured data produced by the verification process.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.metadata IS
'Additional structured verification information.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_results.created_at IS
'Timestamp when the verification result was recorded.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
