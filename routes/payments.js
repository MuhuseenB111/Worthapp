const express = require("express");

const router = express.Router();

/**
 * GET /api/payments
 * Get payment transactions.
 */
router.get("/", (req, res) => {
  try {
    const { userId, status, type } = req.query;

    // Database integration will be added later.
    const payments = [];

    res.status(200).json({
      success: true,
      message: "Payments retrieved successfully.",
      filters: {
        userId: userId || null,
        status: status || null,
        type: type || null
      },
      count: payments.length,
      payments
    });
  } catch (error) {
    console.error("Payments GET error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to retrieve payments."
    });
  }
});

/**
 * GET /api/payments/:id
 * Get a single payment transaction.
 */
router.get("/:id", (req, res) => {
  try {
    const { id } = req.params;

    // Database lookup will be added later.
    const payment = null;

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: "Payment transaction not found.",
        paymentId: id
      });
    }

    res.status(200).json({
      success: true,
      message: "Payment retrieved successfully.",
      payment
    });
  } catch (error) {
    console.error("Payment GET error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to retrieve payment."
    });
  }
});

/**
 * POST /api/payments
 * Create a payment transaction.
 */
router.post("/", (req, res) => {
  try {
    const {
      userId,
      amount,
      currency,
      paymentMethod,
      reference
    } = req.body;

    if (
      !userId ||
      amount === undefined ||
      !currency ||
      !paymentMethod
    ) {
      return res.status(400).json({
        success: false,
        message:
          "userId, amount, currency and paymentMethod are required."
      });
    }

    const numericAmount = Number(amount);

    if (
      Number.isNaN(numericAmount) ||
      numericAmount <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Amount must be a valid number greater than zero."
      });
    }

    const payment = {
      id: `payment_${Date.now()}`,
      userId,
      amount: numericAmount,
      currency,
      paymentMethod,
      reference: reference || `ref_${Date.now()}`,
      status: "pending",
      createdAt: new Date().toISOString()
    };

    res.status(201).json({
      success: true,
      message: "Payment created successfully.",
      payment
    });
  } catch (error) {
    console.error("Payment POST error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to create payment."
    });
  }
});

/**
 * PATCH /api/payments/:id/status
 * Update payment status.
 */
router.patch("/:id/status", (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const allowedStatuses = [
      "pending",
      "processing",
      "completed",
      "failed",
      "cancelled",
      "refunded"
    ];

    if (!status || !allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid payment status.",
        allowedStatuses
      });
    }

    res.status(200).json({
      success: true,
      message: "Payment status updated successfully.",
      payment: {
        id,
        status,
        updatedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error("Payment status error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to update payment status."
    });
  }
});

/**
 * POST /api/payments/:id/refund
 * Request a refund for a payment.
 */
router.post("/:id/refund", (req, res) => {
  try {
    const { id } = req.params;

    res.status(200).json({
      success: true,
      message: "Refund request received.",
      paymentId: id,
      status: "refund_pending",
      createdAt: new Date().toISOString()
    });
  } catch (error) {
    console.error("Refund error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to process refund request."
    });
  }
});

module.exports = router;
