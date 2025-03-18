const express = require('express');
const mongoose = require('mongoose');
const app = express();

app.use(express.json());

// Kết nối MongoDB Atlas
mongoose.connect('mongodb+srv://Hermit_home:fBmPCFVSDCy8Prqe@hermit.qyush.mongodb.net/HermitHome');

// Schema cho sensors
const SensorSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  temperature: Number,
  humidity: Number,
  light: Number,
  timestamp: String,
}, { collection: 'sensors' });

const Sensor = mongoose.model('Sensor', SensorSchema);

// Schema cho current_stats
const CurrentStatsSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true }, // Giữ là String
  temperature: Number,
  humidity: Number,
  light: Number,
  timestamp: String,
}, { collection: 'current_stats' });

const CurrentStats = mongoose.model('CurrentStats', CurrentStatsSchema);

// Schema cho thresholds
const ThresholdSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true, unique: true },
  minTemperature: Number,
  maxTemperature: Number,
  minHumidity: Number,
  maxHumidity: Number,
  minLight: Number,
  maxLight: Number,
  updatedAt: String,
}, { collection: 'thresholds' });

const Threshold = mongoose.model('Threshold', ThresholdSchema);

// API để ESP32 S3 cập nhật dữ liệu cảm biến
app.post('/update-sensors', async (req, res) => {
  try {
    const { userId, temperature, humidity, light } = req.body;
    const timestamp = new Date().toISOString();

    // Bao bọc userId bằng "ObjectId(...)" mà không thêm ngoặc kép thừa
    const formattedUserId = `ObjectId("${userId}")`; // Chỉ một cặp ngoặc kép

    // Cập nhật dữ liệu vào sensors
    await Sensor.updateOne(
      { userId: formattedUserId },
      {
        $set: {
          userId: formattedUserId,
          temperature,
          humidity,
          light,
          timestamp,
        },
      },
      { upsert: true }
    );

    // Cập nhật dữ liệu vào current_stats
    await CurrentStats.updateOne(
      { userId: formattedUserId },
      {
        $set: {
          userId: formattedUserId,
          temperature,
          humidity,
          light,
          timestamp,
        },
      },
      { upsert: true }
    );

    res.status(200).send('Cập nhật dữ liệu cảm biến thành công');
  } catch (error) {
    res.status(500).send('Lỗi khi cập nhật dữ liệu cảm biến: ' + error.message);
  }
});

// API để ESP32 S3 lấy ngưỡng từ thresholds
app.get('/get-thresholds/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const userIdObject = new mongoose.Types.ObjectId(userId);

    const thresholds = await Threshold.findOne({ userId: userIdObject });
    if (!thresholds) {
      return res.status(404).send('Không tìm thấy ngưỡng cho userId: ' + userId);
    }
    res.status(200).json(thresholds);
  } catch (error) {
    res.status(500).send('Lỗi khi lấy ngưỡng: ' + error.message);
  }
});

// API để lấy dữ liệu current_stats
app.get('/get-current-stats/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const formattedUserId = `ObjectId("${userId}")`; // Chỉ một cặp ngoặc kép
    const currentStats = await CurrentStats.findOne({ userId: formattedUserId });
    if (!currentStats) {
      return res.status(404).send('Không tìm thấy dữ liệu current_stats cho userId: ' + userId);
    }
    res.status(200).json(currentStats);
  } catch (error) {
    res.status(500).send('Lỗi khi lấy current_stats: ' + error.message);
  }
});

// API kiểm tra kết nối
app.get('/test', (req, res) => {
  res.status(200).send('API đang chạy và kết nối thành công!');
});

// Sử dụng cổng 3000
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server chạy trên port ${PORT}`);
});