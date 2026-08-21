const express = require("express");

const router = express.Router();

/**
 * WORTHAPP ADDRESS ROUTES
 * FILE 37
 *
 * Handles user delivery and billing addresses.
 */

/**
 * GET /addresses
 * Get all addresses for the current user.
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Addresses retrieved successfully",
    data: []
  });
});

/**
 * POST /addresses
 * Add a new address.
 */
router.post("/", (req, res) => {
  const {
    fullName,
    phone,
    addressLine,
    city,
    state,
    country,
    postalCode,
    isDefault = false
  } = req.body || {};

  if (!fullName || !phone || !addressLine || !city || !state || !country) {
    return res.status(400).json({
      success: false,
      message: "fullName, phone, addressLine, city, state and country are required"
    });
  }

  return res.status(201).json({
    success: true,
    message: "Address added successfully",
    data: {
      fullName,
      phone,
      addressLine,
      city,
      state,
      country,
      postalCode: postalCode || null,
      isDefault: Boolean(isDefault)
    }
  });
});

/**
 * GET /addresses/:addressId
 * Get one address.
 */
router.get("/:addressId", (req, res) => {
  const { addressId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Address retrieved successfully",
    data: {
      addressId
    }
  });
});

/**
 * PATCH /addresses/:addressId
 * Update an address.
 */
router.patch("/:addressId", (req, res) => {
  const { addressId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Address updated successfully",
    data: {
      addressId,
      updates: req.body || {}
    }
  });
});

/**
 * DELETE /addresses/:addressId
 * Delete an address.
 */
router.delete("/:addressId", (req, res) => {
  const { addressId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Address deleted successfully",
    data: {
      addressId
    }
  });
});

/**
 * PATCH /addresses/:addressId/default
 * Set an address as the default address.
 */
router.patch("/:addressId/default", (req, res) => {
  const { addressId } = req.params;

  return res.status(200).json({
    success: true,
    message: "Default address updated successfully",
    data: {
      addressId,
      isDefault: true
    }
  });
});

module.exports = router;
