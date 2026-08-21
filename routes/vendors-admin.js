const express = require("express");

const router = express.Router();

/*
|--------------------------------------------------------------------------
| ADMIN VENDOR MANAGEMENT ROUTES
|--------------------------------------------------------------------------
| Wannan module zai kula da ayyukan Admin da suka shafi vendors.
| Database integration da admin authorization za a haɗa su daga baya.
|--------------------------------------------------------------------------
*/

// Get all vendors
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Admin vendors endpoint is working",
    data: {
      vendors: [],
      total: 0
    }
  });
});

// Get a single vendor
router.get("/:vendorId", (req, res) => {
  const { vendorId } = req.params;

  res.status(200).json({
    success: true,
    message: "Admin vendor details endpoint is ready",
    data: {
      vendorId
    }
  });
});

// Approve a vendor
router.patch("/:vendorId/approve", (req, res) => {
  const { vendorId } = req.params;

  res.status(200).json({
    success: true,
    message: "Vendor approval endpoint is ready",
    data: {
      vendorId,
      status: "approved"
    }
  });
});

// Suspend a vendor
router.patch("/:vendorId/suspend", (req, res) => {
  const { vendorId } = req.params;

  res.status(200).json({
    success: true,
    message: "Vendor suspension endpoint is ready",
    data: {
      vendorId,
      status: "suspended"
    }
  });
});

// Activate a vendor
router.patch("/:vendorId/activate", (req, res) => {
  const { vendorId } = req.params;

  res.status(200).json({
    success: true,
    message: "Vendor activation endpoint is ready",
    data: {
      vendorId,
      status: "active"
    }
  });
});

module.exports = router;
