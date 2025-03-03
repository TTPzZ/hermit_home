import 'package:flutter/material.dart';
import 'dart:ui';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  // Dữ liệu mẫu (đảm bảo có trường date)
  final List<Map<String, dynamic>> statsData = const [
    {
      'date': '03/03/2025',
      'time': '08:00',
      'humidity': 65,
      'temperature': 28,
      'light': 300,
    },
    {
      'date': '03/03/2025',
      'time': '08:30',
      'humidity': 66,
      'temperature': 27,
      'light': 310,
    },
    {
      'date': '03/03/2025',
      'time': '09:00',
      'humidity': 64,
      'temperature': 29,
      'light': 290,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100], // Đổi màu nền thành xám nhạt giống MainScreen
      child: ListView.builder(
        itemCount: statsData.length,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemBuilder: (context, index) {
          final data = statsData[index];
          return AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: 1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Card(
                    elevation: 0,
                    color: Colors.white.withOpacity(0.9),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFF5F5F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ngày: ${data['date'] ?? 'N/A'}', // Thêm kiểm tra null
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black12,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Thời gian: ${data['time'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black12,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildStatRow(
                              icon: Icons.opacity,
                              label: 'Độ ẩm',
                              value: '${data['humidity'] ?? 'N/A'}',
                              unit: '%',
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow(
                              icon: Icons.thermostat,
                              label: 'Nhiệt độ',
                              value: '${data['temperature'] ?? 'N/A'}',
                              unit: '°C',
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow(
                              icon: Icons.light_mode,
                              label: 'Ánh sáng',
                              value: '${data['light'] ?? 'N/A'}',
                              unit: 'lux',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(
          '$label: $value$unit',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            shadows: [
              Shadow(
                color: Colors.black12,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
