const express = require("express");

const router = express.Router();

/*
|--------------------------------------------------------------------------
| ADMIN USER MANAGEMENT ROUTES
|--------------------------------------------------------------------------
| Wannan module zai kula da ayyukan Admin da suka shafi users.
| Database integration da authentication/authorization za a haɗa su
| a matakan gaba.
|--------------------------------------------------------------------------
*/

// Get users
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Admin users endpoint is working",
    data: {
      users: [],
      total: 0
    }
  });
});

// Get a single user
router.get("/:userId", (req, res) => {
  const { userId } = req.params;

  res.status(200).json({
    success: true,
    message: "Admin user details endpoint is ready",
    data: {
      userId
    }
  });
});

// Suspend a user
router.patch("/:userId/suspend", (req, res) => {
  const { userId } = req.params;

  res.status(200).json({
    success: true,
    message: "User suspension endpoint is ready",
    data: {
      userId,
      status: "suspended"
    }
  });
});

// Activate a user
router.patch("/:userId/activate", (req, res) => {
  const { userId } = req.params;

  res.status(200).json({
    success: true,
    message: "User activation endpoint is ready",
    data: {
      userId,
      status: "active"
    }
  });
});

// Update user role
router.patch("/:userId/role", (req, res) => {
  const { userId } = req.params;
  const { role } = req.body;

  res.status(200).json({
    success: true,
    message: "User role endpoint is ready",
    data: {
      userId,
      role: role || null
    }
  });
});

module.exports = router;
