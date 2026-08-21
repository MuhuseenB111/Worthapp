const express = require("express");

const router = express.Router();

// Temporary in-memory shipping storage.
// This will later be connected to the database.
const shipments = [];

/**
 * GET /shipping
 * Get all shipments
 */
router.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    count: shipments.length,
    shipments
  });
});

/**
 * GET /shipping/:id
 * Get a single shipment
 */
router.get("/:id", (req, res) => {
  const shipment = shipments.find(
    (item) => item.id === req.params.id
  );

  if (!shipment) {
    return res.status(404).json({
      success: false,
      message: "Shipment not found"
    });
  }

  res.status(200).json({
    success: true,
    shipment
  });
});

/**
 * POST /shipping
 * Create a shipment
 */
router.post("/", (req, res) => {
  const {
    orderId,
    userId,
    carrier,
    deliveryAddress,
    estimatedDelivery
  } = req.body;

  if (!orderId || !userId || !deliveryAddress) {
    return res.status(400).json({
      success: false,
      message: "orderId, userId and deliveryAddress are required"
    });
  }

  const shipment = {
    id: String(Date.now()),
    orderId,
    userId,
    carrier: carrier || null,
    trackingNumber: `WT-${Date.now()}`,
    deliveryAddress,
    estimatedDelivery: estimatedDelivery || null,
    status: "pending",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  shipments.push(shipment);

  res.status(201).json({
    success: true,
    message: "Shipment created successfully",
    shipment
  });
});

/**
 * PATCH /shipping/:id/status
 * Update shipment status
 */
router.patch("/:id/status", (req, res) => {
  const shipment = shipments.find(
    (item) => item.id === req.params.id
  );

  if (!shipment) {
    return res.status(404).json({
      success: false,
      message: "Shipment not found"
    });
  }

  const allowedStatuses = [
    "pending",
    "processing",
    "shipped",
    "in_transit",
    "out_for_delivery",
    "delivered",
    "cancelled"
  ];

  const { status } = req.body;

  if (!allowedStatuses.includes(status)) {
    return res.status(400).json({
      success: false,
      message: "Invalid shipment status"
    });
  }

  shipment.status = status;
  shipment.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Shipment status updated successfully",
    shipment
  });
});

/**
 * PATCH /shipping/:id
 * Update shipment information
 */
router.patch("/:id", (req, res) => {
  const shipment = shipments.find(
    (item) => item.id === req.params.id
  );

  if (!shipment) {
    return res.status(404).json({
      success: false,
      message: "Shipment not found"
    });
  }

  const {
    carrier,
    deliveryAddress,
    estimatedDelivery
  } = req.body;

  if (carrier !== undefined) {
    shipment.carrier = carrier;
  }

  if (deliveryAddress !== undefined) {
    shipment.deliveryAddress = deliveryAddress;
  }

  if (estimatedDelivery !== undefined) {
    shipment.estimatedDelivery = estimatedDelivery;
  }

  shipment.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Shipment updated successfully",
    shipment
  });
});

/**
 * DELETE /shipping/:id
 * Cancel a shipment
 */
router.delete("/:id", (req, res) => {
  const shipment = shipments.find(
    (item) => item.id === req.params.id
  );

  if (!shipment) {
    return res.status(404).json({
      success: false,
      message: "Shipment not found"
    });
  }

  shipment.status = "cancelled";
  shipment.updatedAt = new Date().toISOString();

  res.status(200).json({
    success: true,
    message: "Shipment cancelled successfully",
    shipment
  });
});

module.exports = router;
