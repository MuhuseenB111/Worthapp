-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION RESULT ACTION REVIEW FINDING ACTION EVIDENCE
-- Migration: 056
-- =========================================================

BEGIN;

-- =========================================================
-- VERIFICATION RESULT ACTION REVIEW FINDING ACTION EVIDENCE
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

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

    evidence_role VARCHAR(40) NOT NULL
        CHECK (
            evidence_role IN (
                'supporting',
                'contradicting',
                'confirming',
                'supplementary',
                'resolution',
                'correction',
                'escalation',
                'verification'
            )
        ),

    status VARCHAR(30) NOT NULL DEFAULT 'attached'
        CHECK (
            status IN (
                'attached',
                'reviewed',
                'accepted',
                'rejected',
                'superseded',
                'removed'
            )
        ),

    relevance_score NUMERIC(5,2)
        CHECK (
            relevance_score IS NULL
            OR (
                relevance_score >= 0
                AND relevance_score <= 100
            )
        ),

    reason TEXT,

    notes TEXT,

    previous_state JSONB,

    current_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_finding_action_evidence_finding_action
        FOREIGN KEY (finding_action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_finding
        FOREIGN KEY (finding_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_findings(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_review
        FOREIGN KEY (review_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_reviews(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_review_action
        FOREIGN KEY (review_action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_action_review_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_action
        FOREIGN KEY (action_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_result
        FOREIGN KEY (result_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_results(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verification_result_actions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_source
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_finding_action_evidence_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_finding_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    finding_action_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_finding
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    finding_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_review
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    review_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_review_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    review_action_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_action
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    action_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_result
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    result_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_verification
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_source
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_decision
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_workflow
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_reversal
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_actor
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_role
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    evidence_role
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_status
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    status
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_updated
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    updated_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_finding_action_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    finding_action_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_finding_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    finding_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_review_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    review_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_evidence_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    evidence_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_finding_action_evidence_reversal_created
ON wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence IS
'Evidence associations attached to lifecycle actions performed on wallet reversal approval review findings.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.finding_action_id IS
'Finding action associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.finding_id IS
'Finding associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.review_id IS
'Review record associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.review_action_id IS
'Review action associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.action_id IS
'Original verification result action associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.result_id IS
'Verification result associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.verification_id IS
'Evidence verification result action associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.evidence_id IS
'Source evidence attached to the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.decision_id IS
'Approval decision associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.workflow_id IS
'Approval workflow associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.reversal_id IS
'Wallet adjustment reversal associated with this evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.actor_id IS
'Authorized user or system actor responsible for attaching or updating the evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.evidence_role IS
'Role of the evidence in supporting, contradicting, confirming, resolving, correcting, escalating, or verifying the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.status IS
'Current lifecycle status of the evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.relevance_score IS
'Relevance score assigned to the evidence for the finding action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.reason IS
'Reason for attaching or changing the evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.notes IS
'Additional information about the evidence association.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.previous_state IS
'Structured evidence association state before the latest update.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.current_state IS
'Current structured evidence association state.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.metadata IS
'Additional structured evidence association metadata.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.created_at IS
'Timestamp when the evidence association was created.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_result_action_review_finding_action_evidence.updated_at IS
'Timestamp when the evidence association was last updated.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
