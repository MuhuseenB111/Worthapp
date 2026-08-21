const express = require("express");

const router = express.Router();

/**
 * ADMIN PAYMENT MANAGEMENT
 * ------------------------
 * Handles administrative payment operations.
 *
 * NOTE:
 * Authentication/role protection can be connected
 * through the existing middleware later without
 * changing the payment logic below.
 */

// Get all payments
router.get("/", async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: "Payments retrieved successfully",
      data: []
    });
  } catch (error) {
    console.error("Admin payments error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve payments"
    });
  }
});

// Get payment by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    res.status(200).json({
      success: true,
      message: "Payment retrieved successfully",
      data: {
        id
      }
    });
  } catch (error) {
    console.error("Admin payment details error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve payment"
    });
  }
});

// Confirm payment
router.patch("/:id/confirm", async (req, res) => {
  try {
    const { id } = req.params;

    res.status(200).json({
      success: true,
      message: "Payment confirmed successfully",
      paymentId: id,
      status: "confirmed"
    });
  } catch (error) {
    console.error("Confirm payment error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to confirm payment"
    });
  }
});

// Reject payment
router.patch("/:id/reject", async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body || {};

    res.status(200).json({
      success: true,
      message: "Payment rejected successfully",
      paymentId: id,
      status: "rejected",
      reason: reason || null
    });
  } catch (error) {
    console.error("Reject payment error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to reject payment"
    });
  }
});

// Update payment status
router.patch("/:id/status", async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body || {};

    const allowedStatuses = [
      "pending",
      "processing",
      "confirmed",
      "failed",
      "rejected",
      "refunded"
    ];

    if (!status || !allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid payment status",
        allowedStatuses
      });
    }

    res.status(200).json({
      success: true,
      message: "Payment status updated successfully",
      paymentId: id,
      status
    });
  } catch (error) {
    console.error("Update payment status error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to update payment status"
    });
  }
});

module.exports = router;
