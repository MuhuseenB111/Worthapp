const express = require("express");

const router = express.Router();

/**
 * ADMIN DISPUTES MANAGEMENT
 * -------------------------
 * Handles administrative dispute management.
 *
 * NOTE:
 * Authentication and admin-role protection
 * can be connected through existing middleware.
 */

// Get all disputes
router.get("/", async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: "Disputes retrieved successfully",
      data: []
    });
  } catch (error) {
    console.error("Admin disputes error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve disputes"
    });
  }
});

// Get dispute by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    res.status(200).json({
      success: true,
      message: "Dispute retrieved successfully",
      data: {
        id
      }
    });
  } catch (error) {
    console.error("Dispute details error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve dispute"
    });
  }
});

// Review dispute
router.patch("/:id/review", async (req, res) => {
  try {
    const { id } = req.params;

    res.status(200).json({
      success: true,
      message: "Dispute marked for review",
      disputeId: id,
      status: "under_review"
    });
  } catch (error) {
    console.error("Review dispute error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to review dispute"
    });
  }
});

// Resolve dispute
router.patch("/:id/resolve", async (req, res) => {
  try {
    const { id } = req.params;
    const { resolution } = req.body || {};

    res.status(200).json({
      success: true,
      message: "Dispute resolved successfully",
      disputeId: id,
      status: "resolved",
      resolution: resolution || null
    });
  } catch (error) {
    console.error("Resolve dispute error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to resolve dispute"
    });
  }
});

// Reject dispute
router.patch("/:id/reject", async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body || {};

    res.status(200).json({
      success: true,
      message: "Dispute rejected successfully",
      disputeId: id,
      status: "rejected",
      reason: reason || null
    });
  } catch (error) {
    console.error("Reject dispute error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to reject dispute"
    });
  }
});

// Update dispute status
router.patch("/:id/status", async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body || {};

    const allowedStatuses = [
      "open",
      "under_review",
      "resolved",
      "rejected",
      "closed"
    ];

    if (!status || !allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid dispute status",
        allowedStatuses
      });
    }

    res.status(200).json({
      success: true,
      message: "Dispute status updated successfully",
      disputeId: id,
      status
    });
  } catch (error) {
    console.error("Update dispute status error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to update dispute status"
    });
  }
});

module.exports = router;
