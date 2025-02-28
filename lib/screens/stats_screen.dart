import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  // Dữ liệu mẫu (sẽ thay bằng dữ liệu thực từ thiết bị sau)
  final List<Map<String, dynamic>> statsData = const [
    {'time': '08:00', 'humidity': 65, 'temperature': 28, 'light': 300},
    {'time': '08:30', 'humidity': 66, 'temperature': 27, 'light': 310},
    {'time': '09:00', 'humidity': 64, 'temperature': 29, 'light': 290},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần bên trái: danh sách thông số
        SizedBox(
          width:
              MediaQuery.of(context).size.width * 0.5, // Chiếm 50% chiều ngang
          child: ListView.builder(
            itemCount: statsData.length,
            itemBuilder: (context, index) {
              final data = statsData[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thời gian: ${data['time']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Độ ẩm: ${data['humidity']}%'),
                        Text('Nhiệt độ: ${data['temperature']}°C'),
                        Text('Ánh sáng: ${data['light']} lux'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Phần bên phải: có thể để trống hoặc thêm nội dung sau
        const Expanded(child: Center(child: Text('Chi tiết (tùy chọn)'))),
      ],
    );
  }
}
