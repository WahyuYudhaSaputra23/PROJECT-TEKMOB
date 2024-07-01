const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const connectDB = require('./config');
const path = require('path');

const app = express();

// Middleware
app.use(bodyParser.json());
app.use(cors());

connectDB();

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
// Routes
app.use('/api/users', require('./routes/users'));
app.use('/api/shifts', require('./routes/shifts'));
app.use('/api/attendance', require('./routes/attendance'));
app.use('/api/branches', require('./routes/branch'));

const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`Server running on port ${port}`));
