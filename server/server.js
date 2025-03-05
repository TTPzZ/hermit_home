require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ✅ Kết nối MongoDB Atlas
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("✅ Kết nối MongoDB thành công!"))
    .catch(err => console.log("❌ Lỗi kết nối MongoDB:", err));

// 📌 Tạo Schema MongoDB
const SensorSchema = new mongoose.Schema({
    temperature: Number,
    humidity: Number,
    light: Number,
    createdAt: { type: Date, default: Date.now }
});

const Sensor = mongoose.model('Sensor', SensorSchema);

// 🔹 API nhận dữ liệu từ ESP32-S3
app.post('/sensor', async (req, res) => {
    try {
        const { temperature, humidity, light } = req.body;
        const newSensorData = new Sensor({ temperature, humidity, light });
        await newSensorData.save();
        res.status(201).json({ message: "✅ Dữ liệu đã được lưu!" });
    } catch (err) {
        res.status(500).json({ error: "❌ Lỗi khi lưu dữ liệu" });
    }
});

// 🔹 API lấy dữ liệu từ MongoDB
app.get('/sensor', async (req, res) => {
    try {
        const data = await Sensor.find().sort({ createdAt: -1 }).limit(10);
        res.json(data);
    } catch (err) {
        res.status(500).json({ error: "❌ Lỗi khi lấy dữ liệu" });
    }
});

const UserSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true }
});
const User = mongoose.model('User', UserSchema);

app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user || user.password !== password) {
            return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng!' });
        }
        res.json({ message: 'Đăng nhập thành công!', user });
    } catch (err) {
        res.status(500).json({ message: 'Lỗi server' });
    }
});



// Chạy server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`));
