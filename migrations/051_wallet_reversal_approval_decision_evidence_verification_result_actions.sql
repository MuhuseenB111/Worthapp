-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTIONS
-- Migration: 051
-- =========================================================

BEGIN;

-- =========================================================
-- VERIFICATION RESULT ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_result_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

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
                'reviewed',
                'confirmed',
                'challenged',
                'corrected',
                'recalculated',
                'rechecked',
                'accepted',
                'rejected',
                'overridden',
                'escalated',
                'reopened',
                'closed',
                'cancelled',
                'failed'
            )
        ),

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

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

    previous_result JSONB,

    new_result JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_verification_result_actions_result
        FOREIGN KEY (result_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_results(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_actions_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_actions_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_actions_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_actions_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_verification_result_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_result
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    result_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_verification
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_evidence
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_decision
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_workflow
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_reversal
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_actor
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_type
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    action_type
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_status
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    new_status
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_created
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_result_created
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    result_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_verification_result_actions_verification_created
ON wallet_reversal_approval_decision_evidence_verification_result_actions(
    verification_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_result_actions IS
'Audit trail of actions performed against individual evidence verification results.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.result_id IS
'Verification result associated with this action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.verification_id IS
'Evidence verification record associated with the result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.evidence_id IS
'Evidence record associated with the result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.decision_id IS
'Approval decision associated with the result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.workflow_id IS
'Approval workflow associated with the result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.reversal_id IS
'Wallet adjustment reversal associated with the result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.actor_id IS
'Authorized user or system actor responsible for the result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.action_type IS
'Specific action performed against the verification result.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.previous_status IS
'Verification result status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.new_status IS
'Verification result status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.previous_confidence_score IS
'Confidence score before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.new_confidence_score IS
'Confidence score after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.reason IS
'Reason associated with the result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.notes IS
'Additional notes associated with the result action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.previous_result IS
'Structured verification result before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.new_result IS
'Structured verification result after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.metadata IS
'Additional structured audit information.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_actions.created_at IS
'Timestamp when the result action was recorded.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
