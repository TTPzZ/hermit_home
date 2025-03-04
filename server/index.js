require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// 🔗 Kết nối MongoDB (Dán MongoDB Connection String vào đây)
mongoose.connect(process.env.MONGO_URI)
.then(() => console.log('🟢 Connected to MongoDB'))
  .catch(err => console.error('🔴 MongoDB connection error:', err));

// 📌 Tạo model lưu dữ liệu từ ESP32
const SensorData = mongoose.model('SensorData', new mongoose.Schema({
  temperature: Number,
  humidity: Number,
  light: Number,
  createdAt: { type: Date, default: Date.now }
}));

// 📤 API để ESP32 gửi dữ liệu lên MongoDB
app.post('/upload', async (req, res) => {
  try {
    const { temperature, humidity, light } = req.body;
    const data = new SensorData({ temperature, humidity, light });
    await data.save();
    res.json({ success: true, message: 'Data saved successfully!' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// 📥 API để Flutter lấy dữ liệu từ MongoDB
app.get('/get-data', async (req, res) => {
  try {
    const data = await SensorData.find().sort({ createdAt: -1 }).limit(10);
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// 🚀 Chạy server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🟢 Server running on port ${PORT}`));
