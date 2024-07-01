const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

const connectDB = async () => {
  try {
    await mongoose.connect('mongodb+srv://IFrame:NctpWyDPfkMVKKs1@cluster0.tjebuk3.mongodb.net/', {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('Database berhasil terkoneksi.');
  } catch (error) {
    console.error('Database gagal terkoneksi:', error);
    process.exit(1);
  }
};

module.exports = connectDB;
