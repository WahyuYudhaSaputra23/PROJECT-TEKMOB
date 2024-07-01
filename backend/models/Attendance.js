const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
  userID: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  userRole: { 
    type: String, 
    enum: ['Service Employees', 'Rental Employees'], 
    required: true 
  },
  jobdesk: { 
    type: String, 
    enum: ['Marketing', 'Pelaksana Project', 'Customer Service', 'Maintenance'], 
    required: true 
  },
  shiftIDs: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Shift', required: true }],
  branch: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', required: true },
  date: { type: Date, required: true },
  checkIn: { type: Date },
  checkOut: { type: Date },
  notes: { type: String },
  workDuration: { type: String }
});

// Pre-save hook to calculate work duration
attendanceSchema.pre('save', function(next) {
  if (this.checkIn && this.checkOut) {
    const durationInMs = this.checkOut - this.checkIn;
    const hours = Math.floor(durationInMs / 3600000);
    const minutes = Math.floor((durationInMs % 3600000) / 60000);
    this.workDuration = `${hours}h ${minutes}m`;
  } else {
    this.workDuration = '0h 0m';
  }
  next();
});

module.exports = mongoose.model('Attendance', attendanceSchema);
