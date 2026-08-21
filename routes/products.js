const express = require("express");

const router = express.Router();

/*
 * WORTHAPP
 * Product Routes
 *
 * Wannan route yana kula da:
 * - Product listing
 * - Product details
 * - Category filtering
 * - Pagination
 *
 * Database integration za a haɗa daga baya.
 */

// GET /products
// Samun jerin products
router.get("/", async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      category,
      sellerId,
      status = "active"
    } = req.query;

    const parsedPage = Math.max(
      parseInt(page, 10) || 1,
      1
    );

    const parsedLimit = Math.min(
      Math.max(parseInt(limit, 10) || 20, 1),
      100
    );

    /*
     * Database query za a haɗa nan.
     * Ba mu saka fake products ba.
     */

    return res.status(200).json({
      success: true,
      message: "Products endpoint is ready",
      data: {
        products: [],
        pagination: {
          page: parsedPage,
          limit: parsedLimit
        },
        filters: {
          category: category || null,
          sellerId: sellerId || null,
          status
        }
      }
    });
  } catch (error) {
    next(error);
  }
});


// GET /products/:productId
// Samun cikakken bayanin product guda ɗaya
router.get("/:productId", async (req, res, next) => {
  try {
    const { productId } = req.params;

    if (!productId || productId.length > 100) {
      return res.status(400).json({
        success: false,
        message: "Invalid product ID"
      });
    }

    /*
     * Database lookup za a haɗa nan.
     */

    return res.status(404).json({
      success: false,
      message: "Product not found"
    });
  } catch (error) {
    next(error);
  }
});


module.exports = router;
