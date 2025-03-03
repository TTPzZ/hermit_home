import 'package:flutter/material.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double temperature = 28.0;
  double humidity = 65.0;
  double light = 300.0;

  bool isTemperatureSensorEnabled = true;
  bool isHumiditySensorEnabled = true;
  bool isLightSensorEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              margin: const EdgeInsets.only(top: 3),
              width: MediaQuery.of(context).size.width * 0.99,
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  40,
                ), // Bo tròn đều 4 góc với bán kính 40
                // borderRadius: const BorderRadius.only(
                //   bottomLeft: Radius.circular(40),
                //   bottomRight: Radius.circular(40),
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Camera Bể Nuôi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlRow(
                  'Nhiệt độ',
                  '${temperature.toStringAsFixed(1)}°C',
                  isTemperatureSensorEnabled,
                  Icons.thermostat,
                  () {
                    setState(() {
                      isTemperatureSensorEnabled = !isTemperatureSensorEnabled;
                    });
                  },
                ),
                const SizedBox(height: 15),
                _buildControlRow(
                  'Độ ẩm',
                  '${humidity.toStringAsFixed(1)}%',
                  isHumiditySensorEnabled,
                  Icons.opacity,
                  () {
                    setState(() {
                      isHumiditySensorEnabled = !isHumiditySensorEnabled;
                    });
                  },
                ),
                const SizedBox(height: 15),
                _buildControlRow(
                  'Ánh sáng',
                  '${light.toStringAsFixed(0)} lux',
                  isLightSensorEnabled,
                  Icons.light_mode,
                  () {
                    setState(() {
                      isLightSensorEnabled = !isLightSensorEnabled;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlRow(
    String label,
    String value,
    bool isEnabled,
    IconData icon,
    VoidCallback onToggle,
  ) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: isEnabled ? 1.0 : 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isEnabled ? 1.0 : 0.5,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: isEnabled,
                    onChanged: (value) => onToggle(),
                    activeTrackColor: Colors.blueAccent,
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
