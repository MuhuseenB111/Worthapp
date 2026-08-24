-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW FINDING ACTIONS
-- Migration: 055
-- =========================================================

BEGIN;

-- =========================================================
-- VERIFICATION RESULT ACTION REVIEW FINDING ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

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

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'acknowledged',
                'investigation_started',
                'evidence_requested',
                'evidence_received',
                'verification_requested',
                'verification_completed',
                'correction_requested',
                'correction_received',
                'escalated',
                'deescalated',
                'resolved',
                'reopened',
                'dismissed',
                'cancelled',
                'overridden'
            )
        ),

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    previous_severity VARCHAR(20),

    new_severity VARCHAR(20),

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

    notes TEXT,

    previous_state JSONB,

    new_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_review_finding_actions_finding
        FOREIGN KEY (finding_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_review
        FOREIGN KEY (review_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_reviews(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_review_action
        FOREIGN KEY (review_action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_action
        FOREIGN KEY (action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_result
        FOREIGN KEY (result_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_results(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_finding_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_finding
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    finding_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_review
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    review_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_review_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    review_action_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    action_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_result
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    result_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_verification
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_decision
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_workflow
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_reversal
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_actor
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_type
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    action_type
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    new_status
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_severity
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    new_severity
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_finding_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    finding_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_review_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    review_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_review_action_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    review_action_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_result_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    result_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_reversal_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    reversal_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_review_finding_actions_actor_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(
    actor_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions IS
'Audit trail of lifecycle actions performed on findings identified during wallet reversal approval evidence verification reviews.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.finding_id IS
'Finding associated with the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.review_id IS
'Review record associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.review_action_id IS
'Review action from the verification result action review action history associated with this finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.action_id IS
'Original verification result action associated with the finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.result_id IS
'Verification result associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.verification_id IS
'Evidence verification associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.evidence_id IS
'Evidence associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.decision_id IS
'Approval decision associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.workflow_id IS
'Approval workflow associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.reversal_id IS
'Wallet adjustment reversal associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.actor_id IS
'Authorized user or system actor responsible for the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.action_type IS
'Lifecycle action performed against the review finding.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.previous_status IS
'Finding status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.new_status IS
'Finding status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.previous_severity IS
'Finding severity before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.new_severity IS
'Finding severity after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.decision IS
'Decision associated with the finding action when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.reason IS
'Reason associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.notes IS
'Additional information associated with the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.previous_state IS
'Structured finding state captured before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.new_state IS
'Structured finding state captured after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.metadata IS
'Additional structured finding action metadata.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions.created_at IS
'Timestamp when the finding action was recorded.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
