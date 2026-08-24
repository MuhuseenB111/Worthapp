-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW ACTIONS
-- Migration: 053
-- =========================================================

BEGIN;

-- =========================================================
-- VERIFICATION RESULT ACTION REVIEW ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_result_action_review_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    review_id UUID NOT NULL,

    action_id UUID NOT NULL,

    result_id UUID NOT NULL,

    verification_id UUID NOT NULL,

    evidence_id UUID NOT NULL,

    decision_id UUID NOT NULL,

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'started',
                'review_started',
                'evidence_checked',
                'result_checked',
                'finding_added',
                'finding_updated',
                'finding_resolved',
                'approved',
                'rejected',
                'correction_requested',
                'escalated',
                'held',
                'completed',
                'cancelled',
                'reopened',
                'overridden'
            )
        ),

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    previous_decision VARCHAR(30),

    new_decision VARCHAR(30),

    previous_confidence_score NUMERIC(5,2)
        CHECK (
            previous_confidence_score IS NULL
            OR (
                previous_confidence_score >= 0
                AND previous_confidence_score <= 100
            )
        ),

    new_confidence_score NUMERIC(5,2)
        CHECK (
            new_confidence_score IS NULL
            OR (
                new_confidence_score >= 0
                AND new_confidence_score <= 100
            )
        ),

    reason TEXT,

    notes TEXT,

    previous_state JSONB,

    new_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_review_actions_review
        FOREIGN KEY (review_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_reviews(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_actions_action
        FOREIGN KEY (action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_actions_result
        FOREIGN KEY (result_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_results(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_actions_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_actions_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_actions_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_actions_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_review_actions_review
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    review_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    action_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_result
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    result_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_verification
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_decision
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_workflow
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_reversal
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_actor
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_type
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    action_type
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    new_status
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_review_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    review_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_result_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    result_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_actions_reversal_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_result_action_review_actions IS
'Audit trail of actions performed during reviews of wallet reversal evidence verification result actions.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.review_id IS
'Review record associated with this review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.action_id IS
'Original verification result action associated with the review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.result_id IS
'Verification result associated with the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.verification_id IS
'Evidence verification associated with the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.evidence_id IS
'Evidence associated with the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.decision_id IS
'Approval decision associated with the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.workflow_id IS
'Approval workflow associated with the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.reversal_id IS
'Wallet adjustment reversal associated with the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.actor_id IS
'Authorized user or system actor responsible for the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.action_type IS
'Type of action performed during the verification result review.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.previous_status IS
'Review status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.new_status IS
'Review status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.previous_decision IS
'Review decision before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.new_decision IS
'Review decision after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.previous_confidence_score IS
'Confidence score before the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.new_confidence_score IS
'Confidence score after the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.reason IS
'Reason associated with the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.notes IS
'Additional information about the review action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.previous_state IS
'Structured review state before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.new_state IS
'Structured review state after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.metadata IS
'Additional structured audit metadata.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_actions.created_at IS
'Timestamp when the review action was recorded.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
