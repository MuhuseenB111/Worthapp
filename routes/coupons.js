const express = require("express");

const router = express.Router();

/**
 * WORTHAPP COUPON ROUTES
 * FILE 38
 *
 * Handles coupon and promotional discount operations.
 */

/**
 * GET /coupons
 * Get available coupons.
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Coupons retrieved successfully",
    data: []
  });
});

/**
 * POST /coupons
 * Create a new coupon.
 */
router.post("/", (req, res) => {
  const {
    code,
    discountType,
    discountValue,
    minimumOrderAmount = 0,
    expiresAt
  } = req.body || {};

  if (!code || !discountType || discountValue === undefined) {
    return res.status(400).json({
      success: false,
      message: "code, discountType and discountValue are required"
    });
  }

  if (!["percentage", "fixed"].includes(discountType)) {
    return res.status(400).json({
      success: false,
      message: "discountType must be percentage or fixed"
    });
  }

  if (Number(discountValue) <= 0) {
    return res.status(400).json({
      success: false,
      message: "discountValue must be greater than zero"
    });
  }

  return res.status(201).json({
    success: true,
    message: "Coupon created successfully",
    data: {
      code: String(code).trim().toUpperCase(),
      discountType,
      discountValue: Number(discountValue),
      minimumOrderAmount: Number(minimumOrderAmount) || 0,
      expiresAt: expiresAt || null
    }
  });
});

/**
 * POST /coupons/validate
 * Validate a coupon before applying it to an order.
 */
router.post("/validate", (req, res) => {
  const { code, orderAmount = 0 } = req.body || {};

  if (!code) {
    return res.status(400).json({
      success: false,
      message: "Coupon code is required"
    });
  }

  if (Number(orderAmount) < 0) {
    return res.status(400).json({
      success: false,
      message: "orderAmount cannot be negative"
    });
  }

  return res.status(200).json({
    success: true,
    message: "Coupon validation completed",
    data: {
      code: String(code).trim().toUpperCase(),
      orderAmount: Number(orderAmount),
      valid: false,
      discountAmount: 0
    }
  });
});

/**
 * GET /coupons/:couponId
 * Get a single coupon.
 */
router.get("/:couponId", (req, res) => {
  const { couponId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Coupon retrieved successfully",
    data: {
      couponId
    }
  });
});

/**
 * PATCH /coupons/:couponId
 * Update a coupon.
 */
router.patch("/:couponId", (req, res) => {
  const { couponId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Coupon updated successfully",
    data: {
      couponId,
      updates: req.body || {}
    }
  });
});

/**
 * DELETE /coupons/:couponId
 * Delete a coupon.
 */
router.delete("/:couponId", (req, res) => {
  const { couponId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Coupon deleted successfully",
    data: {
      couponId
    }
  });
});

module.exports = router;
