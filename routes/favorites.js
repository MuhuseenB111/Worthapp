const express = require("express");

const router = express.Router();

/**
 * WORTHAPP FAVORITES ROUTES
 * FILE 35
 *
 * Handles user favorite/wishlist actions.
 */

/**
 * GET /favorites
 * Get the current user's favorites.
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Favorites retrieved successfully",
    data: []
  });
});

/**
 * POST /favorites
 * Add a product to favorites.
 */
router.post("/", (req, res) => {
  const { productId } = req.body || {};

  if (!productId) {
    return res.status(400).json({
      success: false,
      message: "productId is required"
    });
  }

  return res.status(201).json({
    success: true,
    message: "Product added to favorites",
    data: {
      productId
    }
  });
});

/**
 * DELETE /favorites/:productId
 * Remove a product from favorites.
 */
router.delete("/:productId", (req, res) => {
  const { productId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Product removed from favorites",
    data: {
      productId
    }
  });
});

/**
 * GET /favorites/:productId
 * Check whether a product is in favorites.
 */
router.get("/:productId", (req, res) => {
  const { productId } = req.params;

  return res.status(200).json({
    success: true,
    productId,
    isFavorite: false
  });
});

module.exports = router;
