const express = require("express");

const router = express.Router();

// Temporary in-memory dispute storage.
// This will later be connected to the database.
const disputes = [];

/**
 * GET /disputes
 * Get all disputes
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    count: disputes.length,
    disputes
  });
});

/**
 * GET /disputes/:id
 * Get a single dispute
 */
router.get("/:id", (req, res) => {
  const dispute = disputes.find(
    (item) => item.id === req.params.id
  );

  if (!dispute) {
    return res.status(404).json({
      success: false,
      message: "Dispute not found"
    });
  }

  res.status(200).json({
    success: true,
    dispute
  });
});

/**
 * POST /disputes
 * Create a new dispute
 */
router.post("/", (req, res) => {
  const {
    orderId,
    userId,
    vendorId,
    reason,
    description
  } = req.body;

  if (!orderId || !userId || !reason) {
    return res.status(400).json({
      success: false,
      message: "orderId, userId and reason are required"
    });
  }

  const dispute = {
    id: String(Date.now()),
    orderId,
    userId,
    vendorId: vendorId || null,
    reason,
    description: description || "",
    status: "open",
    resolution: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  disputes.push(dispute);

  res.status(201).json({
    success: true,
    message: "Dispute created successfully",
    dispute
  });
});

/**
 * PATCH /disputes/:id/status
 * Update dispute status
 */
router.patch("/:id/status", (req, res) => {
  const dispute = disputes.find(
    (item) => item.id === req.params.id
  );

  if (!dispute) {
    return res.status(404).json({
      success: false,
      message: "Dispute not found"
    });
  }

  const allowedStatuses = [
    "open",
    "under_review",
    "awaiting_response",
    "resolved",
    "rejected",
    "closed",
    "cancelled"
  ];

  const { status } = req.body;

  if (!allowedStatuses.includes(status)) {
    return res.status(400).json({
      success: false,
      message: "Invalid dispute status"
    });
  }

  dispute.status = status;
  dispute.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Dispute status updated successfully",
    dispute
  });
});

/**
 * PATCH /disputes/:id/resolve
 * Add a resolution to a dispute
 */
router.patch("/:id/resolve", (req, res) => {
  const dispute = disputes.find(
    (item) => item.id === req.params.id
  );

  if (!dispute) {
    return res.status(404).json({
      success: false,
      message: "Dispute not found"
    });
  }

  const { resolution } = req.body;

  if (!resolution) {
    return res.status(400).json({
      success: false,
      message: "Resolution is required"
    });
  }

  dispute.resolution = resolution;
  dispute.status = "resolved";
  dispute.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Dispute resolved successfully",
    dispute
  });
});

/**
 * DELETE /disputes/:id
 * Cancel an open dispute
 */
router.delete("/:id", (req, res) => {
  const dispute = disputes.find(
    (item) => item.id === req.params.id
  );

  if (!dispute) {
    return res.status(404).json({
      success: false,
      message: "Dispute not found"
    });
  }

  if (dispute.status !== "open") {
    return res.status(400).json({
      success: false,
      message: "Only open disputes can be cancelled"
    });
  }

  dispute.status = "cancelled";
  dispute.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Dispute cancelled successfully",
    dispute
  });
});

module.exports = router;
