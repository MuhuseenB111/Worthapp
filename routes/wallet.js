const express = require("express");

const router = express.Router();

/**
 * WORTHAPP WALLET ROUTES
 * FILE 39
 *
 * Handles wallet information and wallet operations.
 *
 * NOTE:
 * Real balance changes and transfers must be handled
 * through the database/payment service layer.
 */

/**
 * GET /wallet
 * Get the current user's wallet summary.
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Wallet retrieved successfully",
    data: {
      currency: "NGN",
      balance: 0,
      availableBalance: 0,
      pendingBalance: 0,
      status: "active"
    }
  });
});

/**
 * GET /wallet/balance
 * Get the current wallet balance.
 */
router.get("/balance", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Wallet balance retrieved successfully",
    data: {
      currency: "NGN",
      balance: 0,
      availableBalance: 0,
      pendingBalance: 0
    }
  });
});

/**
 * GET /wallet/transactions
 * Get wallet transaction history.
 */
router.get("/transactions", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Wallet transactions retrieved successfully",
    data: []
  });
});

/**
 * POST /wallet/deposit
 * Create a deposit request.
 */
router.post("/deposit", (req, res) => {
  const { amount, currency = "NGN", reference } = req.body || {};

  if (amount === undefined || Number(amount) <= 0) {
    return res.status(400).json({
      success: false,
      message: "A valid deposit amount is required"
    });
  }

  return res.status(201).json({
    success: true,
    message: "Deposit request created successfully",
    data: {
      amount: Number(amount),
      currency,
      reference: reference || null,
      status: "pending"
    }
  });
});

/**
 * POST /wallet/withdraw
 * Create a withdrawal request.
 */
router.post("/withdraw", (req, res) => {
  const { amount, currency = "NGN", destination } = req.body || {};

  if (amount === undefined || Number(amount) <= 0) {
    return res.status(400).json({
      success: false,
      message: "A valid withdrawal amount is required"
    });
  }

  if (!destination) {
    return res.status(400).json({
      success: false,
      message: "Withdrawal destination is required"
    });
  }

  return res.status(201).json({
    success: true,
    message: "Withdrawal request created successfully",
    data: {
      amount: Number(amount),
      currency,
      destination,
      status: "pending"
    }
  });
});

/**
 * POST /wallet/transfer
 * Create a wallet-to-wallet transfer request.
 */
router.post("/transfer", (req, res) => {
  const { amount, currency = "NGN", recipientId, reference } = req.body || {};

  if (amount === undefined || Number(amount) <= 0) {
    return res.status(400).json({
      success: false,
      message: "A valid transfer amount is required"
    });
  }

  if (!recipientId) {
    return res.status(400).json({
      success: false,
      message: "recipientId is required"
    });
  }

  return res.status(201).json({
    success: true,
    message: "Transfer request created successfully",
    data: {
      amount: Number(amount),
      currency,
      recipientId,
      reference: reference || null,
      status: "pending"
    }
  });
});

module.exports = router;
