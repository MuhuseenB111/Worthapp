-- =========================================================
-- WORTHAPP
-- WALLET REVERSAL APPROVAL WORKFLOW APPROVAL EVENTS
-- Migration: 044
-- =========================================================

BEGIN;

-- =========================================================
-- WALLET REVERSAL APPROVAL WORKFLOW APPROVAL EVENTS
-- =========================================================

CREATE TABLE IF NOT EXISTS wallet_reversal_approval_workflow_approval_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    workflow_id UUID NOT NULL,

    reversal_id UUID NOT NULL,

    workflow_approval_id UUID NOT NULL,

    actor_id UUID,

    event_type VARCHAR(40) NOT NULL
        CHECK (
            event_type IN (
                'created',
                'requested',
                'assigned',
                'reminded',
                'viewed',
                'started',
                'approved',
                'rejected',
                'held',
                'manual_review',
                'expired',
                'cancelled',
                'skipped',
                'overridden',
                'reopened',
                'escalated',
                'completed',
                'failed'
            )
        ),

    previous_status VARCHAR(30),

    new_status VARCHAR(30),

    previous_decision VARCHAR(30),

    new_decision VARCHAR(30),

    approval_level INTEGER
        CHECK (
            approval_level IS NULL
            OR approval_level > 0
        ),

    actor_role VARCHAR(60),

    reason TEXT,

    notes TEXT,

    previous_state JSONB,

    new_state JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_reversal_workflow_approval_events_workflow
        FOREIGN KEY (workflow_id)
        REFERENCES wallet_reversal_approval_workflows(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_workflow_approval_events_reversal
        FOREIGN KEY (reversal_id)
        REFERENCES wallet_adjustment_reversals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_workflow_approval_events_approval
        FOREIGN KEY (workflow_approval_id)
        REFERENCES wallet_reversal_approval_workflow_approvals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reversal_workflow_approval_events_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id)
        ON DELETE RESTRICT,

    CONSTRAINT wallet_reversal_workflow_approval_events_decision_check
        CHECK (
            previous_decision IS NULL
            OR previous_decision IN (
                'approve',
                'reject',
                'hold',
                'manual_review'
            )
        ),

    CONSTRAINT wallet_reversal_workflow_approval_events_new_decision_check
        CHECK (
            new_decision IS NULL
            OR new_decision IN (
                'approve',
                'reject',
                'hold',
                'manual_review'
            )
        )
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_workflow
ON wallet_reversal_approval_workflow_approval_events(
    workflow_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_reversal
ON wallet_reversal_approval_workflow_approval_events(
    reversal_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_approval
ON wallet_reversal_approval_workflow_approval_events(
    workflow_approval_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_actor
ON wallet_reversal_approval_workflow_approval_events(
    actor_id
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_type
ON wallet_reversal_approval_workflow_approval_events(
    event_type
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_status
ON wallet_reversal_approval_workflow_approval_events(
    new_status
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_level
ON wallet_reversal_approval_workflow_approval_events(
    workflow_id,
    approval_level
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_created
ON wallet_reversal_approval_workflow_approval_events(
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_workflow_created
ON wallet_reversal_approval_workflow_approval_events(
    workflow_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_approval_created
ON wallet_reversal_approval_workflow_approval_events(
    workflow_approval_id,
    created_at
);

CREATE INDEX IF NOT EXISTS
idx_reversal_workflow_approval_events_reversal_created
ON wallet_reversal_approval_workflow_approval_events(
    reversal_id,
    created_at
);

-- =========================================================
-- COMMENTS
-- =========================================================

COMMENT ON TABLE wallet_reversal_approval_workflow_approval_events IS
'Immutable audit trail of lifecycle events occurring on individual wallet reversal workflow approvals.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.workflow_id IS
'Approval workflow associated with this event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.reversal_id IS
'Wallet adjustment reversal associated with this event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.workflow_approval_id IS
'Specific workflow approval record associated with this event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.actor_id IS
'User or authorized system actor responsible for the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.event_type IS
'Lifecycle event performed against the workflow approval.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.previous_status IS
'Approval status before the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.new_status IS
'Approval status after the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.previous_decision IS
'Approval decision before the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.new_decision IS
'Approval decision after the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.approval_level IS
'Approval hierarchy level associated with the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.actor_role IS
'Role of the actor responsible for the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.reason IS
'Reason associated with the approval event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.notes IS
'Additional information associated with the approval event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.previous_state IS
'Structured approval state captured before the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.new_state IS
'Structured approval state captured after the event.';

COMMENT ON COLUMN wallet_reversal_approval_workflow_approval_events.metadata IS
'Additional structured audit information associated with the event.';

-- =========================================================
-- MIGRATION COMPLETE
-- =========================================================

COMMIT;
