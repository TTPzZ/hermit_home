const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors());

const PORT = 3000;
const MONGO_URI = "mongodb://localhost:27017/muonhon_tank";

// Kết nối MongoDB với logging
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log(" MongoDB connected successfully"))
    .catch(err => console.error(" MongoDB connection failed:", err));

const SensorSchema = new mongoose.Schema({
    temperature: Number,
    humidity: Number,
    light: Number,
    timestamp: { type: Date, default: Date.now }
});
const Sensor = mongoose.model("Sensor", SensorSchema);

const ControlSchema = new mongoose.Schema({
    temperature: Number,
    humidity: Number,
    light: Number,
    timestamp: { type: Date, default: Date.now }
});
const Control = mongoose.model("Control", ControlSchema);

app.post("/api/sensors", async (req, res) => {
    try {
        const sensorData = new Sensor(req.body);
        await sensorData.save();
        console.log(" Sensor data saved:", req.body);
        res.json({ message: "Data saved" });
    } catch (err) {
        console.error(" Error saving sensor data:", err);
        res.status(500).json({ error: "Internal server error" });
    }
});

app.get("/api/sensors/latest", async (req, res) => {
    try {
        const latestData = await Sensor.findOne().sort({ timestamp: -1 });
        console.log(" Latest sensor data retrieved:", latestData);
        res.json(latestData);
    } catch (err) {
        console.error(" Error retrieving latest sensor data:", err);
        res.status(500).json({ error: "Internal server error" });
    }
});

app.post("/api/control", async (req, res) => {
    try {
        const controlData = new Control(req.body);
        await controlData.save();
        console.log(" Control command saved:", req.body);
        res.json({ message: "Control command saved" });
    } catch (err) {
        console.error(" Error saving control command:", err);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Lắng nghe server với logging
app.listen(PORT, () => console.log(` Server running on http://localhost:${PORT}`));