const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ShiftSchema = new Schema({
    shiftName: { type: String, required: true },
    startTime: { type: String, required: true },
    endTime: { type: String, required: true }
});

module.exports = mongoose.model('Shift', ShiftSchema);
