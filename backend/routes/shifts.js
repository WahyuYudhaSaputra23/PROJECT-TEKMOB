const express = require('express');
const router = express.Router();
const Shift = require('../models/Shift');

// GET all shifts
router.get('/', async (req, res) => {
  try {
    const shifts = await Shift.find();
    res.json(shifts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
