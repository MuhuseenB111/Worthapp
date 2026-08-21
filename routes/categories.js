const express = require("express");

const router = express.Router();

/*
 * WORTHAPP
 * Category Routes
 *
 * Wannan route yana kula da:
 * - Category listing
 * - Category details
 * - Category status
 *
 * Database integration za a haɗa daga baya.
 */

// GET /categories
// Samun jerin categories
router.get("/", async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 50,
      status = "active"
    } = req.query;

    const parsedPage = Math.max(
      parseInt(page, 10) || 1,
      1
    );

    const parsedLimit = Math.min(
      Math.max(parseInt(limit, 10) || 50, 1),
      100
    );

    /*
     * Database query za a haɗa nan.
     * Ba mu saka fake categories ba.
     */

    return res.status(200).json({
      success: true,
      message: "Categories endpoint is ready",
      data: {
        categories: [],
        pagination: {
          page: parsedPage,
          limit: parsedLimit
        },
        filters: {
          status
        }
      }
    });
  } catch (error) {
    next(error);
  }
});


// GET /categories/:categoryId
// Samun bayanin category guda ɗaya
router.get("/:categoryId", async (req, res, next) => {
  try {
    const { categoryId } = req.params;

    if (!categoryId || categoryId.length > 100) {
      return res.status(400).json({
        success: false,
        message: "Invalid category ID"
      });
    }

    /*
     * Database lookup za a haɗa nan.
     */

    return res.status(404).json({
      success: false,
      message: "Category not found"
    });
  } catch (error) {
    next(error);
  }
});


module.exports = router;
