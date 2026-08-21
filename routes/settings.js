const express = require("express");

const router = express.Router();

/**
 * GET /api/settings
 * Get settings for the current user.
 */
router.get("/", (req, res) => {
  try {
    const settings = {
      language: "en",
      theme: "system",
      notifications: {
        messages: true,
        security: true,
        system: true
      },
      privacy: {
        profileVisibility: "public",
        showOnlineStatus: true,
        allowMessages: true
      }
    };

    res.status(200).json({
      success: true,
      message: "Settings retrieved successfully.",
      settings
    });
  } catch (error) {
    console.error("Settings GET error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to retrieve settings."
    });
  }
});

/**
 * PATCH /api/settings
 * Update user settings.
 */
router.patch("/", (req, res) => {
  try {
    const {
      language,
      theme,
      notifications,
      privacy
    } = req.body;

    const updatedSettings = {
      language,
      theme,
      notifications,
      privacy,
      updatedAt: new Date().toISOString()
    };

    res.status(200).json({
      success: true,
      message: "Settings updated successfully.",
      settings: updatedSettings
    });
  } catch (error) {
    console.error("Settings PATCH error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to update settings."
    });
  }
});

/**
 * PATCH /api/settings/language
 * Update application language.
 */
router.patch("/language", (req, res) => {
  try {
    const { language } = req.body;

    if (!language || typeof language !== "string") {
      return res.status(400).json({
        success: false,
        message: "A valid language is required."
      });
    }

    res.status(200).json({
      success: true,
      message: "Language updated successfully.",
      language
    });
  } catch (error) {
    console.error("Language update error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to update language."
    });
  }
});

/**
 * PATCH /api/settings/notifications
 * Update notification preferences.
 */
router.patch("/notifications", (req, res) => {
  try {
    const {
      messages,
      security,
      system
    } = req.body;

    const notificationSettings = {
      messages: messages !== undefined ? Boolean(messages) : true,
      security: security !== undefined ? Boolean(security) : true,
      system: system !== undefined ? Boolean(system) : true
    };

    res.status(200).json({
      success: true,
      message: "Notification settings updated successfully.",
      notifications: notificationSettings
    });
  } catch (error) {
    console.error("Notification settings error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to update notification settings."
    });
  }
});

/**
 * PATCH /api/settings/privacy
 * Update privacy preferences.
 */
router.patch("/privacy", (req, res) => {
  try {
    const {
      profileVisibility,
      showOnlineStatus,
      allowMessages
    } = req.body;

    const privacySettings = {
      profileVisibility:
        profileVisibility || "public",

      showOnlineStatus:
        showOnlineStatus !== undefined
          ? Boolean(showOnlineStatus)
          : true,

      allowMessages:
        allowMessages !== undefined
          ? Boolean(allowMessages)
          : true
    };

    res.status(200).json({
      success: true,
      message: "Privacy settings updated successfully.",
      privacy: privacySettings
    });
  } catch (error) {
    console.error("Privacy settings error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to update privacy settings."
    });
  }
});

module.exports = router;
