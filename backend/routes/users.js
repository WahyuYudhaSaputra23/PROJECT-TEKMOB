const express = require('express');
const path = require('path');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');

// Konfigurasi multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({ storage: storage });

// Route untuk melayani file gambar
router.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Route untuk operasi CRUD pada User
router.get('/', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: `Error retrieving users: ${err.message}` });
  }
});

router.post('/', upload.single('image'), async (req, res) => {
  const user = new User({
    userName: req.body.userName,
    password: req.body.password,
    email: req.body.email,
    image: req.file ? `/uploads/${req.file.filename}` : '',
    fullName: req.body.fullName
  });
  try {
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(user.password, salt);
    const newUser = await user.save();
    res.status(201).json(newUser);
  } catch (err) {
    res.status(400).json({ message: `Error creating user: ${err.message}` });
  }
});

router.put('/:id', upload.single('image'), async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.userName = req.body.userName || user.userName;
    if (req.body.password) {
      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(req.body.password, salt);
    }
    user.email = req.body.email || user.email;
    user.fullName = req.body.fullName || user.fullName;
    user.image = req.file ? `/uploads/${req.file.filename}` : user.image;

    const updatedUser = await user.save();
    res.json(updatedUser);
  } catch (err) {
    res.status(400).json({ message: `Error updating user: ${err.message}` });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    console.log('Received request to delete user with ID:', req.params.id); // Tambahkan logging di sini
    const user = await User.findById(req.params.id);
    if (!user) {
      console.log('User not found');
      return res.status(404).json({ message: 'User not found' });
    }
    await User.findByIdAndDelete(req.params.id); // Gunakan findByIdAndDelete
    console.log('User deleted successfully');
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    console.error('Error deleting user:', err); // Tambahkan logging di sini
    res.status(500).json({ message: `Error deleting user: ${err.message}` });
  }
});

// Route untuk login
router.post('/login', async (req, res) => {
  try {
    const { userName, password } = req.body;
    console.log(`Received login request: userName=${userName}, password=${password}`);

    // Ubah 'userName' menjadi 'email' jika database menggunakan email
    const user = await User.findOne({ email: userName });
    if (!user) {
      console.log('Login failed: User not found');
      return res.status(400).json({ message: 'Invalid username or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.log('Login failed: Incorrect password');
      return res.status(400).json({ message: 'Invalid username or password' });
    }

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, {
      expiresIn: '1h'
    });

    console.log('Login successful');
    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id, // Menggunakan id bukan _id
        fullName: user.fullName,
        jobDesk: user.jobDesk,
        image: user.image
      }
    });
  } catch (err) {
    console.error(`Error logging in: ${err.message}`);
    res.status(500).json({ message: `Error logging in: ${err.message}` });
  }
});

module.exports = router;
