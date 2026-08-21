const express = require("express");

const router = express.Router();

/**
 * CATEGORIES ADMIN
 * Admin management for marketplace categories
 */

// Get category statistics
router.get("/stats/overview", async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        totalCategories: 0,
        activeCategories: 0,
        inactiveCategories: 0
      }
    });
  } catch (error) {
    console.error("Category statistics error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve category statistics"
    });
  }
});

// Get all categories
router.get("/", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "Categories retrieved successfully",
      data: []
    });
  } catch (error) {
    console.error("Admin categories error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve categories"
    });
  }
});

// Get category by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    res.json({
      success: true,
      message: "Category retrieved successfully",
      data: {
        id
      }
    });
  } catch (error) {
    console.error("Category details error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve category"
    });
  }
});

// Create category
router.post("/", async (req, res) => {
  try {
    const { name, description, status } = req.body;

    if (!name) {
      return res.status(400).json({
        success: false,
        message: "Category name is required"
      });
    }

    res.status(201).json({
      success: true,
      message: "Category created successfully",
      data: {
        name,
        description: description || "",
        status: status || "active"
      }
    });
  } catch (error) {
    console.error("Create category error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to create category"
    });
  }
});

// Update category
router.patch("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, status } = req.body;

    const allowedStatuses = ["active", "inactive"];

    if (status && !allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid category status"
      });
    }

    res.json({
      success: true,
      message: "Category updated successfully",
      data: {
        id,
        name,
        description,
        status
      }
    });
  } catch (error) {
    console.error("Update category error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to update category"
    });
  }
});

// Delete category
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    res.json({
      success: true,
      message: "Category deleted successfully",
      data: {
        id
      }
    });
  } catch (error) {
    console.error("Delete category error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to delete category"
    });
  }
});

module.exports = router;
