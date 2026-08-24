-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE VERIFICATIONS
-- Migration: 048
-- =========================================================

BEGIN;

-- =========================================================
-- EVIDENCE VERIFICATION HISTORY
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    evidence_id UUID NOT NULL,

    decision_id UUID NOT NULL,

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    verifier_id UUID,

    previous_status VARCHAR(30),

    new_status VARCHAR(30) NOT NULL
        CHECK (
            new_status IN (
                'pending',
                'verified',
                'rejected',
                'expired',
                'unavailable'
            )
        ),

    verification_action VARCHAR(40) NOT NULL
        CHECK (
            verification_action IN (
                'submitted',
                'review_started',
                'verified',
                'rejected',
                'expired',
                'restored',
                'reopened',
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

    CONSTRAINT fk_reversal_approval_evidence_verifications_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES wallet_reversal_approval_decision_evidence(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_evidence_verifications_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_evidence_verifications_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_evidence_verifications_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_evidence_verifications_verifier
        FOREIGN KEY (verifier_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_evidence
ON wallet_reversal_approval_decision_evidence_verifications(
    evidence_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_decision
ON wallet_reversal_approval_decision_evidence_verifications(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_workflow
ON wallet_reversal_approval_decision_evidence_verifications(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_reversal
ON wallet_reversal_approval_decision_evidence_verifications(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_verifier
ON wallet_reversal_approval_decision_evidence_verifications(
    verifier_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_status
ON wallet_reversal_approval_decision_evidence_verifications(
    new_status
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_action
ON wallet_reversal_approval_decision_evidence_verifications(
    verification_action
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_created
ON wallet_reversal_approval_decision_evidence_verifications(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_evidence_created
ON wallet_reversal_approval_decision_evidence_verifications(
    evidence_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_evidence_verifications_decision_created
ON wallet_reversal_approval_decision_evidence_verifications(
    decision_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence_verifications IS
'Historical verification actions performed against evidence associated with wallet reversal approval decisions.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.evidence_id IS
'Evidence record whose verification state changed.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.decision_id IS
'Approval decision associated with the evidence verification.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.workflow_id IS
'Approval workflow associated with the verification event.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.reversal_id IS
'Wallet adjustment reversal associated with the verification event.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.verifier_id IS
'Authorized user or system actor responsible for the verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.previous_status IS
'Evidence verification status before the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.new_status IS
'Evidence verification status after the action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.verification_action IS
'Specific verification lifecycle action performed on the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.reason IS
'Reason associated with the verification action.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.notes IS
'Additional information recorded during verification.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.verification_reference IS
'Reference associated with the verification process.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.content_hash IS
'Cryptographic hash used to track evidence integrity when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.previous_state IS
'Structured evidence state captured before verification.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.new_state IS
'Structured evidence state captured after verification.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.metadata IS
'Additional structured verification information.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence_verifications.created_at IS
'Timestamp at which the verification event was recorded.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
