const express = require("express");

const router = express.Router();

/**
 * WORTHAPP CART ROUTES
 * FILE 36
 *
 * Handles shopping cart actions.
 */

/**
 * GET /cart
 * Get the current user's cart.
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Cart retrieved successfully",
    data: {
      items: [],
      totalItems: 0,
      totalAmount: 0
    }
  });
});

/**
 * POST /cart
 * Add a product to the cart.
 */
router.post("/", (req, res) => {
  const { productId, quantity = 1 } = req.body || {};

  if (!productId) {
    return res.status(400).json({
      success: false,
      message: "productId is required"
    });
  }

  if (!Number.isInteger(quantity) || quantity < 1) {
    return res.status(400).json({
      success: false,
      message: "quantity must be a positive integer"
    });
  }

  return res.status(201).json({
    success: true,
    message: "Product added to cart",
    data: {
      productId,
      quantity
    }
  });
});

/**
 * PATCH /cart/:productId
 * Update product quantity in the cart.
 */
router.patch("/:productId", (req, res) => {
  const { productId } = req.params;
  const { quantity } = req.body || {};

  if (!Number.isInteger(quantity) || quantity < 1) {
    return res.status(400).json({
      success: false,
      message: "quantity must be a positive integer"
    });
  }

  return res.status(200).json({
    success: true,
    message: "Cart quantity updated",
    data: {
      productId,
      quantity
    }
  });
});

/**
 * DELETE /cart/:productId
 * Remove a product from the cart.
 */
router.delete("/:productId", (req, res) => {
  const { productId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Product removed from cart",
    data: {
      productId
    }
  });
});

/**
 * DELETE /cart
 * Clear the current user's cart.
 */
router.delete("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Cart cleared successfully",
    data: {
      items: [],
      totalItems: 0,
      totalAmount: 0
    }
  });
});

module.exports = router;
