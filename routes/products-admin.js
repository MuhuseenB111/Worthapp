const express = require("express");

const router = express.Router();

/*
|--------------------------------------------------------------------------
| ADMIN PRODUCT MANAGEMENT ROUTES
|--------------------------------------------------------------------------
| Wannan module zai kula da ayyukan Admin da suka shafi products.
| Database integration da admin authorization za a haɗa su daga baya.
|--------------------------------------------------------------------------
*/

// Get all products
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Admin products endpoint is working",
    data: {
      products: [],
      total: 0
    }
  });
});

// Get a single product
router.get("/:productId", (req, res) => {
  const { productId } = req.params;

  res.status(200).json({
    success: true,
    message: "Admin product details endpoint is ready",
    data: {
      productId
    }
  });
});

// Approve a product
router.patch("/:productId/approve", (req, res) => {
  const { productId } = req.params;

  res.status(200).json({
    success: true,
    message: "Product approval endpoint is ready",
    data: {
      productId,
      status: "approved"
    }
  });
});

// Reject a product
router.patch("/:productId/reject", (req, res) => {
  const { productId } = req.params;

  res.status(200).json({
    success: true,
    message: "Product rejection endpoint is ready",
    data: {
      productId,
      status: "rejected"
    }
  });
});

// Suspend a product
router.patch("/:productId/suspend", (req, res) => {
  const { productId } = req.params;

  res.status(200).json({
    success: true,
    message: "Product suspension endpoint is ready",
    data: {
      productId,
      status: "suspended"
    }
  });
});

// Activate a product
router.patch("/:productId/activate", (req, res) => {
  const { productId } = req.params;

  res.status(200).json({
    success: true,
    message: "Product activation endpoint is ready",
    data: {
      productId,
      status: "active"
    }
  });
});

module.exports = router;
