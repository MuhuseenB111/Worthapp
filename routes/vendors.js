const express = require("express");

const router = express.Router();

// Temporary in-memory vendor storage.
// This will later be connected to the database.
const vendors = [];

/**
 * GET /vendors
 * Get all vendors
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    count: vendors.length,
    vendors
  });
});

/**
 * GET /vendors/:id
 * Get a single vendor
 */
router.get("/:id", (req, res) => {
  const vendor = vendors.find(
    (item) => item.id === req.params.id
  );

  if (!vendor) {
    return res.status(404).json({
      success: false,
      message: "Vendor not found"
    });
  }

  res.status(200).json({
    success: true,
    vendor
  });
});

/**
 * POST /vendors
 * Create a new vendor
 */
router.post("/", (req, res) => {
  const { name, email, phone, businessName, description } = req.body;

  if (!name || !email || !businessName) {
    return res.status(400).json({
      success: false,
      message: "Name, email and businessName are required"
    });
  }

  const vendor = {
    id: String(Date.now()),
    name,
    email,
    phone: phone || null,
    businessName,
    description: description || "",
    status: "pending",
    verified: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  vendors.push(vendor);

  res.status(201).json({
    success: true,
    message: "Vendor created successfully",
    vendor
  });
});

/**
 * PATCH /vendors/:id
 * Update vendor information
 */
router.patch("/:id", (req, res) => {
  const vendor = vendors.find(
    (item) => item.id === req.params.id
  );

  if (!vendor) {
    return res.status(404).json({
      success: false,
      message: "Vendor not found"
    });
  }

  const {
    name,
    email,
    phone,
    businessName,
    description
  } = req.body;

  if (name !== undefined) vendor.name = name;
  if (email !== undefined) vendor.email = email;
  if (phone !== undefined) vendor.phone = phone;
  if (businessName !== undefined) {
    vendor.businessName = businessName;
  }
  if (description !== undefined) {
    vendor.description = description;
  }

  vendor.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Vendor updated successfully",
    vendor
  });
});

/**
 * PATCH /vendors/:id/verify
 * Verify a vendor
 */
router.patch("/:id/verify", (req, res) => {
  const vendor = vendors.find(
    (item) => item.id === req.params.id
  );

  if (!vendor) {
    return res.status(404).json({
      success: false,
      message: "Vendor not found"
    });
  }

  vendor.verified = true;
  vendor.status = "approved";
  vendor.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Vendor verified successfully",
    vendor
  });
});

/**
 * PATCH /vendors/:id/suspend
 * Suspend a vendor
 */
router.patch("/:id/suspend", (req, res) => {
  const vendor = vendors.find(
    (item) => item.id === req.params.id
  );

  if (!vendor) {
    return res.status(404).json({
      success: false,
      message: "Vendor not found"
    });
  }

  vendor.status = "suspended";
  vendor.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Vendor suspended successfully",
    vendor
  });
});

module.exports = router;
