const express = require("express");

const router = express.Router();

/**
 * GET /api/marketplace
 * Get marketplace listings.
 */
router.get("/", (req, res) => {
  try {
    const { category, search, sellerId } = req.query;

    // Database integration will be added later.
    const listings = [];

    res.status(200).json({
      success: true,
      message: "Marketplace listings retrieved successfully.",
      filters: {
        category: category || null,
        search: search || null,
        sellerId: sellerId || null
      },
      count: listings.length,
      listings
    });
  } catch (error) {
    console.error("Marketplace GET error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to retrieve marketplace listings."
    });
  }
});

/**
 * GET /api/marketplace/:id
 * Get a single marketplace listing.
 */
router.get("/:id", (req, res) => {
  try {
    const { id } = req.params;

    // Database lookup will be added later.
    const listing = null;

    if (!listing) {
      return res.status(404).json({
        success: false,
        message: "Marketplace listing not found.",
        listingId: id
      });
    }

    res.status(200).json({
      success: true,
      message: "Marketplace listing retrieved successfully.",
      listing
    });
  } catch (error) {
    console.error("Marketplace item GET error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to retrieve marketplace listing."
    });
  }
});

/**
 * POST /api/marketplace
 * Create a marketplace listing.
 */
router.post("/", (req, res) => {
  try {
    const {
      sellerId,
      title,
      description,
      category,
      price,
      currency
    } = req.body;

    if (
      !sellerId ||
      !title ||
      !description ||
      !category ||
      price === undefined ||
      !currency
    ) {
      return res.status(400).json({
        success: false,
        message:
          "sellerId, title, description, category, price and currency are required."
      });
    }

    if (Number.isNaN(Number(price)) || Number(price) < 0) {
      return res.status(400).json({
        success: false,
        message: "Price must be a valid non-negative number."
      });
    }

    const listing = {
      id: `listing_${Date.now()}`,
      sellerId,
      title,
      description,
      category,
      price: Number(price),
      currency,
      status: "active",
      createdAt: new Date().toISOString()
    };

    res.status(201).json({
      success: true,
      message: "Marketplace listing created successfully.",
      listing
    });
  } catch (error) {
    console.error("Marketplace POST error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to create marketplace listing."
    });
  }
});

/**
 * PATCH /api/marketplace/:id
 * Update a marketplace listing.
 */
router.patch("/:id", (req, res) => {
  try {
    const { id } = req.params;

    const {
      title,
      description,
      category,
      price,
      currency,
      status
    } = req.body;

    const updatedListing = {
      id,
      title: title || null,
      description: description || null,
      category: category || null,
      price:
        price !== undefined
          ? Number(price)
          : null,
      currency: currency || null,
      status: status || "active",
      updatedAt: new Date().toISOString()
    };

    res.status(200).json({
      success: true,
      message: "Marketplace listing updated successfully.",
      listing: updatedListing
    });
  } catch (error) {
    console.error("Marketplace PATCH error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to update marketplace listing."
    });
  }
});

/**
 * DELETE /api/marketplace/:id
 * Delete a marketplace listing.
 */
router.delete("/:id", (req, res) => {
  try {
    const { id } = req.params;

    res.status(200).json({
      success: true,
      message: "Marketplace listing deleted successfully.",
      listingId: id
    });
  } catch (error) {
    console.error("Marketplace DELETE error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to delete marketplace listing."
    });
  }
});

module.exports = router;
