const express = require("express");

const router = express.Router();

/*
 * Worthapp — Settings Admin Routes
 *
 * Admin endpoints for managing platform settings.
 */

// GET all platform settings
router.get("/", async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: "Settings admin endpoint is working.",
      data: {}
    });
  } catch (error) {
    console.error("Settings admin GET error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to load platform settings."
    });
  }
});

// GET public platform configuration
router.get("/public", async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: "Public settings retrieved successfully.",
      data: {
        platformName: "Worthapp",
        maintenanceMode: false,
        registrationEnabled: true,
        marketplaceEnabled: true,
        messagingEnabled: true
      }
    });
  } catch (error) {
    console.error("Public settings error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to load public settings."
    });
  }
});

// UPDATE platform settings
router.put("/", async (req, res) => {
  try {
    const settings = req.body || {};

    res.status(200).json({
      success: true,
      message: "Platform settings updated successfully.",
      data: settings
    });
  } catch (error) {
    console.error("Settings admin UPDATE error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to update platform settings."
    });
  }
});

// GET a single setting
router.get("/:key", async (req, res) => {
  try {
    const { key } = req.params;

    if (!key) {
      return res.status(400).json({
        success: false,
        message: "Setting key is required."
      });
    }

    res.status(200).json({
      success: true,
      message: "Setting retrieved successfully.",
      data: {
        key,
        value: null
      }
    });
  } catch (error) {
    console.error("Setting details error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to load setting."
    });
  }
});

module.exports = router;
