-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- VERIFICATION ACTIONS
-- Migration: 049
-- =========================================================

BEGIN;

-- =========================================================
-- EVIDENCE VERIFICATION ACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verification_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    verification_id UUID NOT NULL,

    evidence_id UUID NOT NULL,

    decision_id UUID NOT NULL,

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    actor_id UUID,

    action_type VARCHAR(40) NOT NULL
        CHECK (
            action_type IN (
                'submitted',
                'review_started',
                'document_checked',
                'identity_checked',
                'source_checked',
                'integrity_checked',
                'verified',
                'rejected',
                'reopened',
                'restored',
                'manual_review',
                'expired',
                'cancelled',
                'overridden',
                'completed',
                'failed'
            )
        ),

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    decision VARCHAR(30)
        CHECK (
            decision IS NULL
            OR decision IN (
                'approve',
                'reject',
                'hold',
                'manual_review'
            )
        ),

    reason TEXT,

    notes TEXT,

    verification_reference VARCHAR(255),

    content_hash VARCHAR(128),

    previous_state JSONB,

    new_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_evidence_verification_actions_verification
        FOREIGN KEY (verification_id)
        REFERENCES wallet_reversal_approval_decision_evidence_verifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_actions_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_actions_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_actions_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_actions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_evidence_verification_actions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_verification
ON wallet_reversal_approval_decision_evidence_verification_actions(
    verification_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_evidence
ON wallet_reversal_approval_decision_evidence_verification_actions(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_decision
ON wallet_reversal_approval_decision_evidence_verification_actions(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_workflow
ON wallet_reversal_approval_decision_evidence_verification_actions(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_reversal
ON wallet_reversal_approval_decision_evidence_verification_actions(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_actor
ON wallet_reversal_approval_decision_evidence_verification_actions(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_type
ON wallet_reversal_approval_decision_evidence_verification_actions(
    action_type
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_status
ON wallet_reversal_approval_decision_evidence_verification_actions(
    new_status
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_created
ON wallet_reversal_approval_decision_evidence_verification_actions(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_verification_created
ON wallet_reversal_approval_decision_evidence_verification_actions(
    verification_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_evidence_verification_actions_evidence_created
ON wallet_reversal_approval_decision_evidence_verification_actions(
    evidence_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verification_actions IS
'Detailed audit trail of individual actions performed while verifying evidence associated with wallet reversal approval decisions.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.verification_id IS
'Evidence verification record associated with the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.evidence_id IS
'Evidence record associated with the verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.decision_id IS
'Approval decision associated with the evidence verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.workflow_id IS
'Approval workflow associated with the evidence verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.reversal_id IS
'Wallet adjustment reversal associated with the evidence verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.actor_id IS
'Authorized user or system actor who performed the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.action_type IS
'Specific action performed during the evidence verification lifecycle.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.previous_status IS
'Evidence verification status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.new_status IS
'Evidence verification status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.decision IS
'Decision associated with the evidence verification action when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.reason IS
'Reason associated with the verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.notes IS
'Additional notes associated with the verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.verification_reference IS
'External or internal reference associated with the verification process.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.content_hash IS
'Cryptographic hash used to help verify evidence integrity.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.previous_state IS
'Structured evidence state captured before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.new_state IS
'Structured evidence state captured after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.metadata IS
'Additional structured audit information for the verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verification_actions.created_at IS
'Timestamp when the verification action was recorded.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
