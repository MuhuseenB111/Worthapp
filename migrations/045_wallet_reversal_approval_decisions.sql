-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL DECISIONS
-- Migration: 045
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL DECISIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    workflow_approval_id UUID NOT NULL,

    actor_id UUID,

    decision VARCHAR(30) NOT NULL
        CHECK (
            decision IN (
                'approve',
                'reject',
                'hold',
                'manual_review'
            )
        ),

    approval_level INTEGER
        CHECK (
            approval_level IS NULL
            OR approval_level > 0
        ),

    previous_decision VARCHAR(30)
        CHECK (
            previous_decision IS NULL
            OR previous_decision IN (
                'approve',
                'reject',
                'hold',
                'manual_review'
            )
        ),

    status VARCHAR(30) NOT NULL DEFAULT 'recorded'
        CHECK (
            status IN (
                'recorded',
                'accepted',
                'rejected',
                'superseded',
                'cancelled'
            )
        ),

    reason TEXT,

    notes TEXT,

    decision_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    decided_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_approval_decisions_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decisions_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decisions_approval
        FOREIGN KEY (workflow_approval_id)
        REFERENCES wallet_reversal_approval_workflow_approvals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_approval_decisions_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_workflow
ON wallet_reversal_approval_decisions(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_reversal
ON wallet_reversal_approval_decisions(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_approval
ON wallet_reversal_approval_decisions(
    workflow_approval_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_actor
ON wallet_reversal_approval_decisions(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_decision
ON wallet_reversal_approval_decisions(
    decision
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_status
ON wallet_reversal_approval_decisions(
    status
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_level
ON wallet_reversal_approval_decisions(
    workflow_id,
    approval_level
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_decided
ON wallet_reversal_approval_decisions(
    decided_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_workflow_decided
ON wallet_reversal_approval_decisions(
    workflow_id,
    decided_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_approval_decisions_approval_decided
ON wallet_reversal_approval_decisions(
    workflow_approval_id,
    decided_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_decisions IS
'Records formal approval decisions made during wallet reversal approval workflows.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.workflow_id IS
'Approval workflow associated with the decision.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.reversal_id IS
'Wallet adjustment reversal associated with the decision.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.workflow_approval_id IS
'Specific workflow approval associated with the decision.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.actor_id IS
'User or authorized system actor who made the decision.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.decision IS
'Formal decision recorded for the approval request.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.approval_level IS
'Approval hierarchy level at which the decision was made.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.previous_decision IS
'Decision that existed before this decision was recorded.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.status IS
'Lifecycle state of the recorded decision.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.reason IS
'Reason provided for the decision.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.notes IS
'Additional notes associated with the decision.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.decision_state IS
'Structured snapshot of relevant workflow state when the decision was made.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.metadata IS
'Additional structured audit information associated with the decision.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.decided_at IS
'Timestamp at which the decision was made.';

COMMENT ON COLUMN wallet_reversal_approval_decisions.created_at IS
'Timestamp at which the decision record was created.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
