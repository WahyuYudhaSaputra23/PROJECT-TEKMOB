const express = require('express');
const router = express.Router();
const Attendance = require('../models/Attendance');

// GET all attendances or filter by date range and calculate total work duration
router.get('/', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    let query = {};

    if (startDate && endDate) {
      const start = new Date(startDate);
      const end = new Date(endDate);
      end.setDate(end.getDate() + 1);

      query = {
        date: {
          $gte: start,
          $lt: end
        }
      };
    }

    const attendances = await Attendance.find(query).populate('userID shiftIDs branch');
    
    // Calculate total work duration per user
    const userDurations = attendances.reduce((acc, attendance) => {
      if (attendance.userID) {
        const userId = attendance.userID._id.toString();
        const fullName = attendance.userID.fullName;
        const [hours, minutes] = attendance.workDuration.split('h ');
        const durationInMinutes = parseInt(hours) * 60 + parseInt(minutes);

        if (acc[userId]) {
          acc[userId].duration += durationInMinutes;
        } else {
          acc[userId] = { fullName, duration: durationInMinutes };
        }
      }
      return acc;
    }, {});

    const userDurationArray = Object.entries(userDurations).map(([userId, data]) => {
      const hours = Math.floor(data.duration / 60);
      const minutes = data.duration % 60;
      return {
        userId,
        fullName: data.fullName,
        totalWorkDuration: `${hours}h ${minutes}m`
      };
    });

    res.json({ attendances, userDurations: userDurationArray });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Check-In
router.post('/checkin', async (req, res) => {
  const { userID, userRole, jobdesk, shiftIDs, branch, date, checkIn, notes } = req.body;

  const attendance = new Attendance({
    userID,
    userRole,
    jobdesk,
    shiftIDs,
    branch,
    date,
    checkIn,
    notes
  });

  try {
    const newAttendance = await attendance.save();
    res.status(201).json(newAttendance);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Check-Out
router.post('/checkout', async (req, res) => {
  const { userID, date, checkOut } = req.body;

  try {
    let attendance = await Attendance.findOne({ userID, date, checkOut: { $exists: false } });

    if (attendance) {
      attendance.checkOut = checkOut;
      await attendance.save();
      res.status(200).json(attendance);
    } else {
      return res.status(404).json({ message: 'Attendance not found for check-out' });
    }
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

module.exports = router;
