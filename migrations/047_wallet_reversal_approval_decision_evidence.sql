-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- Migration: 047
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL DECISION EVIDENCE
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decision_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    decision_id UUID NOT NULL,

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    actor_id UUID,

    evidence_type VARCHAR(40) NOT NULL
        CHECK (
            evidence_type IN (
                'document',
                'transaction',
                'audit_log',
                'system_event',
                'approval_record',
                'rejection_record',
                'identity_record',
                'security_event',
                'manual_note',
                'external_reference',
                'other'
            )
        ),

    evidence_reference VARCHAR(255),

    title VARCHAR(255),

    description TEXT,

    content_hash VARCHAR(128),

    source VARCHAR(100),

    verification_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            verification_status IN (
                'pending',
                'verified',
                'rejected',
                'expired',
                'unavailable'
            )
        ),

    verified_by UUID,

    verified_at TIMESTAMPTZ,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_approval_decision_evidence_decision
        FOREIGN KEY (decision_id)
        REFERENCES wallet_reversal_approval_decisions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decision_evidence_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decision_evidence_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decision_evidence_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_reversal_approval_decision_evidence_verified_by
        FOREIGN KEY (verified_by)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_reversal_approval_decision_evidence_verification_check
        CHECK (
            (
                verification_status = 'verified'
                AND verified_by IS NOT NULL
                AND verified_at IS NOT NULL
            )
            OR
            verification_status <> 'verified'
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_decision
ON wallet_reversal_approval_decision_evidence(
    decision_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_workflow
ON wallet_reversal_approval_decision_evidence(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_reversal
ON wallet_reversal_approval_decision_evidence(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_actor
ON wallet_reversal_approval_decision_evidence(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_type
ON wallet_reversal_approval_decision_evidence(
    evidence_type
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_status
ON wallet_reversal_approval_decision_evidence(
    verification_status
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_verified_by
ON wallet_reversal_approval_decision_evidence(
    verified_by
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_created
ON wallet_reversal_approval_decision_evidence(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_decision_created
ON wallet_reversal_approval_decision_evidence(
    decision_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_workflow_created
ON wallet_reversal_approval_decision_evidence(
    workflow_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decision_evidence_reversal_created
ON wallet_reversal_approval_decision_evidence(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decision_evidence IS
'Evidence records associated with wallet reversal approval decisions for audit, verification, and dispute investigation.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.decision_id IS
'Approval decision associated with the evidence record.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.workflow_id IS
'Approval workflow associated with the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.reversal_id IS
'Wallet adjustment reversal associated with the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.actor_id IS
'User or authorized system actor who submitted or associated the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.evidence_type IS
'Category of evidence associated with the approval decision.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.evidence_reference IS
'Reference or identifier pointing to the underlying evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.title IS
'Human-readable title of the evidence record.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.description IS
'Description explaining the relevance of the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.content_hash IS
'Cryptographic hash used to verify evidence integrity when applicable.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.source IS
'Origin or system from which the evidence was obtained.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.verification_status IS
'Current verification state of the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.verified_by IS
'User who verified the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.verified_at IS
'Timestamp at which the evidence was verified.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.metadata IS
'Additional structured information associated with the evidence.';

COMMENT ON COLUMN wallet_reversal_approval_decision_evidence.created_at IS
'Timestamp at which the evidence record was created.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
