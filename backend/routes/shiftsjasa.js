const express = require('express');
const router = express.Router();
const ShiftJasa = require('../models/shiftsjasa');

// GET all shiftsjasa
router.get('/', async (req, res) => {
  try {
    const shifts = await ShiftJasa.find();
    res.json(shifts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// CREATE a new shiftjasa
router.post('/', async (req, res) => {
  const shiftJasa = new ShiftJasa({
    shiftName: req.body.shiftName,
    startTime: req.body.startTime,
    endTime: req.body.endTime
  });

  try {
    const newShiftJasa = await shiftJasa.save();
    res.status(201).json(newShiftJasa);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Middleware to get shiftjasa by ID
async function getShiftJasa(req, res, next) {
  let shiftJasa;
  try {
    shiftJasa = await ShiftJasa.findById(req.params.id);
    if (shiftJasa == null) {
      return res.status(404).json({ message: 'Cannot find shiftjasa' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  res.shiftJasa = shiftJasa;
  next();
}

module.exports = router;
