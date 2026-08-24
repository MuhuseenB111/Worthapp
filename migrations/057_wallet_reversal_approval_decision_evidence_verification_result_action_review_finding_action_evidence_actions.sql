-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW FINDING
-- ACTION EVIDENCE ACTIONS
-- Migration: 057
-- =========================================================

BEGIN;

-- =========================================================
-- FINDING ACTION EVIDENCE ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

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

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'created',
                'attached',
                'reviewed',
                'validated',
                'confirmed',
                'challenged',
                'rejected',
                'accepted',
                'replaced',
                'superseded',
                'removed',
                'restored',
                'reclassified',
                'escalated',
                'deescalated',
                'resolved',
                'reopened',
                'overridden',
                'cancelled'
            )
        ),

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    previous_role VARCHAR(40),

    new_role VARCHAR(40),

    previous_relevance_score NUMERIC(5,2)
        CHECK (
            previous_relevance_score IS NULL
            OR (
                previous_relevance_score >= 0
                AND previous_relevance_score <= 100
            )
        ),

    new_relevance_score NUMERIC(5,2)
        CHECK (
            new_relevance_score IS NULL
            OR (
                new_relevance_score >= 0
                AND new_relevance_score <= 100
            )
        ),

    reason TEXT,

    notes TEXT,

    previous_state JSONB,

    new_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_finding_action_evidence_actions_evidence
        FOREIGN KEY (finding_action_evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_finding_action
        FOREIGN KEY (finding_action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_finding
        FOREIGN KEY (finding_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_review
        FOREIGN KEY (review_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_review_action
        FOREIGN KEY (review_action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_action
        FOREIGN KEY (action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_result
        FOREIGN KEY (result_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_results(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_source_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    finding_action_evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_finding_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    finding_action_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_finding
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    finding_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_review
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    review_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_review_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    review_action_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    action_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_result
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    result_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_verification
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_source_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_decision
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_workflow
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_reversal
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_actor
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_type
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    action_type
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    new_status
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_evidence_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    finding_action_evidence_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_finding_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    finding_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_review_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    review_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_evidence_source_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    evidence_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actions_reversal_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions IS
'Audit trail of lifecycle actions performed on evidence associations attached to wallet reversal review finding actions.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.finding_action_evidence_id IS
'Evidence association from migration 056 affected by this action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.finding_action_id IS
'Finding action associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.finding_id IS
'Finding associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.review_id IS
'Review associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.review_action_id IS
'Review action associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.action_id IS
'Original verification result action associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.result_id IS
'Verification result associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.verification_id IS
'Evidence verification record associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.evidence_id IS
'Source evidence associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.decision_id IS
'Approval decision associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.workflow_id IS
'Approval workflow associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.reversal_id IS
'Wallet adjustment reversal associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.actor_id IS
'Authorized user or system actor responsible for the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.action_type IS
'Lifecycle action performed against the finding action evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.previous_status IS
'Evidence association status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.new_status IS
'Evidence association status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.previous_role IS
'Evidence role before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.new_role IS
'Evidence role after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.previous_relevance_score IS
'Relevance score before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.new_relevance_score IS
'Relevance score after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.reason IS
'Reason associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.notes IS
'Additional notes associated with the evidence action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.previous_state IS
'Structured evidence association state before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.new_state IS
'Structured evidence association state after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.metadata IS
'Additional structured audit metadata.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence_actions.created_at IS
'Timestamp when the evidence action was recorded.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
