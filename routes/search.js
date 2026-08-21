const express = require("express");

const router = express.Router();

/**
 * GET /api/search
 * Global search endpoint.
 *
 * Query examples:
 * /api/search?q=muhsin
 * /api/search?q=gold&type=marketplace
 */
router.get("/", (req, res) => {
  try {
    const { q, type } = req.query;

    if (!q || typeof q !== "string" || q.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: "Search query must contain at least 2 characters."
      });
    }

    const query = q.trim();

    const allowedTypes = [
      "all",
      "users",
      "messages",
      "marketplace",
      "knowledge"
    ];

    const searchType = type || "all";

    if (!allowedTypes.includes(searchType)) {
      return res.status(400).json({
        success: false,
        message: "Invalid search type.",
        allowedTypes
      });
    }

    // Database search will be connected later.
    const results = [];

    res.status(200).json({
      success: true,
      message: "Search completed successfully.",
      query,
      type: searchType,
      count: results.length,
      results
    });
  } catch (error) {
    console.error("Search error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to complete search."
    });
  }
});

module.exports = router;
