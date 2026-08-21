const express = require("express");

const router = express.Router();

/*
|--------------------------------------------------------------------------
| ADMIN ROUTES
|--------------------------------------------------------------------------
| Wannan route an tanadar domin ayyukan Admin na Worthapp.
| Za mu ƙara cikakken database logic da permissions a matakan gaba.
|--------------------------------------------------------------------------
*/

// Admin dashboard/status
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Worthapp Admin API is working",
    data: {
      module: "admin",
      status: "active"
    }
  });
});

// Admin system overview
router.get("/overview", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Admin overview endpoint is ready",
    data: {
      users: 0,
      vendors: 0,
      products: 0,
      orders: 0,
      payments: 0,
      disputes: 0
    }
  });
});

module.exports = router;
