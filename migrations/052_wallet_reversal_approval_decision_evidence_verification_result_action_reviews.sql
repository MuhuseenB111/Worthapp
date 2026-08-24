-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEWS
-- Migration: 052
-- =========================================================

BEGIN;

-- =========================================================
-- VERIFICATION RESULT ACTION REVIEWS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_result_action_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    action_id UUID NOT NULL,

    result_id UUID NOT NULL,

    verification_id UUID NOT NULL,

    evidence_id UUID NOT NULL,

    decision_id UUID NOT NULL,

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    reviewer_id UUID,

    review_status VARCHAR(30) NOT NULL
        CHECK (
            review_status IN (
                'pending',
                'in_review',
                'approved',
                'rejected',
                'needs_correction',
                'escalated',
                'completed',
                'cancelled'
            )
        ),

    review_decision VARCHAR(30)
        CHECK (
            review_decision IS NULL
            OR review_decision IN (
                'approve',
                'reject',
                'hold',
                'correct',
                'escalate'
            )
        ),

    review_level INTEGER
        CHECK (
            review_level IS NULL
            OR review_level > 0
        ),

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR (
                confidence_score >= 0
                AND confidence_score <= 100
            )
        ),

    reason TEXT,

    notes TEXT,

    findings JSONB,

    previous_review JSONB,

    current_review JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    reviewed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_verification_result_action_reviews_action
        FOREIGN KEY (action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_action_reviews_result
        FOREIGN KEY (result_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_results(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_action_reviews_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_action_reviews_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_action_reviews_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_action_reviews_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_action_reviews_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_action_reviews_reviewer
        FOREIGN KEY (reviewer_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    action_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_result
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    result_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_verification
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_decision
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_workflow
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_reversal
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_reviewer
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    reviewer_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    review_status
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_decision_type
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    review_decision
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_level
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    review_level
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_reviewed
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    reviewed_at
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_result_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    result_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_action_reviews_reviewer_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_reviews(
    reviewer_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_result_action_reviews IS
'Review records for actions performed against wallet reversal evidence verification results.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.action_id IS
'Verification result action being reviewed.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.result_id IS
'Verification result associated with the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.verification_id IS
'Evidence verification associated with the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.evidence_id IS
'Evidence associated with the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.decision_id IS
'Approval decision associated with the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.workflow_id IS
'Approval workflow associated with the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.reversal_id IS
'Wallet adjustment reversal associated with the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.reviewer_id IS
'Authorized reviewer responsible for reviewing the verification result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.review_status IS
'Current status of the review process.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.review_decision IS
'Decision made by the reviewer.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.review_level IS
'Approval or review level at which the review was performed.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.confidence_score IS
'Reviewer confidence score associated with the verification result review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.reason IS
'Reason for the review decision or status.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.notes IS
'Additional reviewer notes.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.findings IS
'Structured findings produced during the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.previous_review IS
'Previous review state captured before the current review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.current_review IS
'Current structured review state.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.metadata IS
'Additional structured review metadata.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.reviewed_at IS
'Timestamp when the review was completed or updated by the reviewer.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.created_at IS
'Timestamp when the review record was created.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_reviews.updated_at IS
'Timestamp when the review record was last updated.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
