const express = require("express");

const router = express.Router();

/*
 * MARKETPLACE ADMIN ROUTES
 * Worthapp
 *
 * Authentication:
 * These routes expect the main authentication system
 * to have already attached the logged-in user to req.user.
 */

// Admin access protection
function requireAdmin(req, res, next) {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: "Authentication required"
    });
  }

  const role = String(req.user.role || "").toLowerCase();

  if (
    role !== "admin" &&
    role !== "superadmin" &&
    role !== "super_admin"
  ) {
    return res.status(403).json({
      success: false,
      message: "Admin access required"
    });
  }

  next();
}


/**
 * GET /marketplace-admin
 * Marketplace admin overview
 */
router.get("/", requireAdmin, async (req, res) => {
  try {
    res.json({
      success: true,
      section: "marketplace-admin",
      message: "Marketplace admin access granted",
      admin: {
        id: req.user.id || null,
        role: req.user.role || null
      },
      features: [
        "Marketplace overview",
        "Product moderation",
        "Vendor management",
        "Listing approval",
        "Listing suspension",
        "Marketplace reports"
      ]
    });
  } catch (error) {
    console.error("Marketplace admin error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to load marketplace admin"
    });
  }
});


/**
 * GET /marketplace-admin/status
 * Marketplace system status
 */
router.get("/status", requireAdmin, async (req, res) => {
  try {
    res.json({
      success: true,
      marketplace: "online",
      moderation: "active",
      vendorManagement: "active",
      productApproval: "active"
    });
  } catch (error) {
    console.error("Marketplace status error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to get marketplace status"
    });
  }
});


/**
 * POST /marketplace-admin/approve/:productId
 * Approve a marketplace product
 */
router.post("/approve/:productId", requireAdmin, async (req, res) => {
  try {
    const { productId } = req.params;

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: "Product ID is required"
      });
    }

    res.json({
      success: true,
      message: "Marketplace product approved",
      productId,
      approvedBy: req.user.id || null
    });
  } catch (error) {
    console.error("Product approval error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to approve product"
    });
  }
});


/**
 * POST /marketplace-admin/reject/:productId
 * Reject a marketplace product
 */
router.post("/reject/:productId", requireAdmin, async (req, res) => {
  try {
    const { productId } = req.params;
    const { reason } = req.body || {};

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: "Product ID is required"
      });
    }

    res.json({
      success: true,
      message: "Marketplace product rejected",
      productId,
      reason: reason || "Rejected by marketplace administrator",
      rejectedBy: req.user.id || null
    });
  } catch (error) {
    console.error("Product rejection error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to reject product"
    });
  }
});


/**
 * POST /marketplace-admin/suspend/:productId
 * Suspend a marketplace product
 */
router.post("/suspend/:productId", requireAdmin, async (req, res) => {
  try {
    const { productId } = req.params;
    const { reason } = req.body || {};

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: "Product ID is required"
      });
    }

    res.json({
      success: true,
      message: "Marketplace product suspended",
      productId,
      reason: reason || "Suspended by marketplace administrator",
      suspendedBy: req.user.id || null
    });
  } catch (error) {
    console.error("Product suspension error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to suspend product"
    });
  }
});


/**
 * POST /marketplace-admin/restore/:productId
 * Restore a suspended product
 */
router.post("/restore/:productId", requireAdmin, async (req, res) => {
  try {
    const { productId } = req.params;

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: "Product ID is required"
      });
    }

    res.json({
      success: true,
      message: "Marketplace product restored",
      productId,
      restoredBy: req.user.id || null
    });
  } catch (error) {
    console.error("Product restoration error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to restore product"
    });
  }
});


/**
 * GET /marketplace-admin/reports
 * Marketplace moderation reports
 */
router.get("/reports", requireAdmin, async (req, res) => {
  try {
    res.json({
      success: true,
      reports: [],
      total: 0,
      message: "Marketplace reports loaded"
    });
  } catch (error) {
    console.error("Marketplace reports error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to load marketplace reports"
    });
  }
});


module.exports = router;
