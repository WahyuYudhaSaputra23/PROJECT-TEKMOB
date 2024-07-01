const express = require('express');
const router = express.Router();
const Branch = require('../models/Branch');

// GET all branches
router.get('/', async (req, res) => {
  try {
    const branches = await Branch.find();
    res.json(branches);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
