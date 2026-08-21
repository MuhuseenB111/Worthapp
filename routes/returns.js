const express = require("express");

const router = express.Router();

// Temporary in-memory return storage.
// This will later be connected to the database.
const returns = [];

/**
 * GET /returns
 * Get all return requests
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    count: returns.length,
    returns
  });
});

/**
 * GET /returns/:id
 * Get a single return request
 */
router.get("/:id", (req, res) => {
  const returnRequest = returns.find(
    (item) => item.id === req.params.id
  );

  if (!returnRequest) {
    return res.status(404).json({
      success: false,
      message: "Return request not found"
    });
  }

  res.status(200).json({
    success: true,
    return: returnRequest
  });
});

/**
 * POST /returns
 * Create a new return request
 */
router.post("/", (req, res) => {
  const {
    orderId,
    productId,
    userId,
    reason,
    description
  } = req.body;

  if (!orderId || !productId || !userId || !reason) {
    return res.status(400).json({
      success: false,
      message: "orderId, productId, userId and reason are required"
    });
  }

  const returnRequest = {
    id: String(Date.now()),
    orderId,
    productId,
    userId,
    reason,
    description: description || "",
    status: "pending",
    refundStatus: "not_requested",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  returns.push(returnRequest);

  res.status(201).json({
    success: true,
    message: "Return request created successfully",
    return: returnRequest
  });
});

/**
 * PATCH /returns/:id/status
 * Update return request status
 */
router.patch("/:id/status", (req, res) => {
  const returnRequest = returns.find(
    (item) => item.id === req.params.id
  );

  if (!returnRequest) {
    return res.status(404).json({
      success: false,
      message: "Return request not found"
    });
  }

  const allowedStatuses = [
    "pending",
    "approved",
    "rejected",
    "received",
    "completed",
    "cancelled"
  ];

  const { status } = req.body;

  if (!allowedStatuses.includes(status)) {
    return res.status(400).json({
      success: false,
      message: "Invalid return status"
    });
  }

  returnRequest.status = status;
  returnRequest.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Return status updated successfully",
    return: returnRequest
  });
});

/**
 * PATCH /returns/:id/refund
 * Update refund status
 */
router.patch("/:id/refund", (req, res) => {
  const returnRequest = returns.find(
    (item) => item.id === req.params.id
  );

  if (!returnRequest) {
    return res.status(404).json({
      success: false,
      message: "Return request not found"
    });
  }

  const allowedRefundStatuses = [
    "not_requested",
    "requested",
    "processing",
    "refunded",
    "failed"
  ];

  const { refundStatus } = req.body;

  if (!allowedRefundStatuses.includes(refundStatus)) {
    return res.status(400).json({
      success: false,
      message: "Invalid refund status"
    });
  }

  returnRequest.refundStatus = refundStatus;
  returnRequest.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Refund status updated successfully",
    return: returnRequest
  });
});

/**
 * DELETE /returns/:id
 * Cancel a pending return request
 */
router.delete("/:id", (req, res) => {
  const returnRequest = returns.find(
    (item) => item.id === req.params.id
  );

  if (!returnRequest) {
    return res.status(404).json({
      success: false,
      message: "Return request not found"
    });
  }

  if (returnRequest.status !== "pending") {
    return res.status(400).json({
      success: false,
      message: "Only pending return requests can be cancelled"
    });
  }

  returnRequest.status = "cancelled";
  returnRequest.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Return request cancelled successfully",
    return: returnRequest
  });
});

module.exports = router;
