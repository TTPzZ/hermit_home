import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math'; // Để tạo dữ liệu ngẫu nhiên

class StatsScreen extends StatefulWidget {
  final String userId; // Nhận userId từ MainScreen
  const StatsScreen({super.key, required this.userId});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late mongo.Db _db;
  late mongo.DbCollection _statsCollection;
  List<Map<String, dynamic>> statsData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('StatsScreen userId: ${widget.userId}'); // In userId để kiểm tra
    _connectToMongoDB();
  }

  Future<void> _connectToMongoDB() async {
    try {
      await dotenv.load(fileName: ".env");
      final mongoUrl = dotenv.env['MONGO_URL'];
      if (mongoUrl == null || mongoUrl.isEmpty) {
        throw Exception('MONGO_URL không được tìm thấy trong file .env');
      }
      _db = await mongo.Db.create(mongoUrl);
      await _db.open();
      _statsCollection =
          _db.collection('stats'); // Kết nối đến collection stats
      await _fetchStats();
    } catch (e) {
      debugPrint('Lỗi khi kết nối MongoDB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể kết nối đến cơ sở dữ liệu: $e')),
        );
      }
    }
  }

  Future<void> _fetchStats() async {
    try {
      setState(() {
        _isLoading = true; // Hiển thị loading khi làm mới
      });
      final stats = await _statsCollection.find({
        'userId': widget.userId,
        '\$query': {},
        '\$orderby': {'timestamp': -1}, // Sắp xếp giảm dần theo timestamp
      }).toList();
      setState(() {
        statsData = stats.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi khi lấy dữ liệu stats: $e');
      setState(() {
        statsData = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _addRandomStat() async {
    try {
      // Tạo dữ liệu ngẫu nhiên
      final random = Random();
      final newStat = {
        'userId': widget.userId,
        'date': DateTime.now()
            .toString()
            .substring(0, 10), // Lấy ngày hiện tại (YYYY-MM-DD)
        'time': DateTime.now()
            .toString()
            .substring(11, 16), // Lấy giờ hiện tại (HH:MM)
        'humidity': 60 + random.nextInt(20), // Độ ẩm ngẫu nhiên từ 60-80
        'temperature': 25 + random.nextInt(10), // Nhiệt độ ngẫu nhiên từ 25-35
        'light': 200 + random.nextInt(300), // Ánh sáng ngẫu nhiên từ 200-500
        'timestamp': DateTime.now().toUtc().toIso8601String(), // Thêm timestamp
      };

      await _statsCollection.insertOne(newStat);
      await _fetchStats(); // Làm mới danh sách stats sau khi thêm
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã thêm dữ liệu ngẫu nhiên thành công')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi thêm dữ liệu stat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể thêm dữ liệu: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100], // Đổi màu nền thành xám nhạt giống MainScreen
        child: RefreshIndicator(
          onRefresh: _fetchStats, // Vuốt xuống để làm mới
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : statsData.isEmpty
                  ? const Center(child: Text('Không có dữ liệu thống kê'))
                  : ListView.builder(
                      itemCount: statsData.length,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
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
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Card(
                                  elevation: 0,
                                  color: Colors.white.withOpacity(0.9),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xFFF5F5F5)
                                        ],
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            value:
                                                '${data['humidity'] ?? 'N/A'}',
                                            unit: '%',
                                          ),
                                          const SizedBox(height: 8),
                                          _buildStatRow(
                                            icon: Icons.thermostat,
                                            label: 'Nhiệt độ',
                                            value:
                                                '${data['temperature'] ?? 'N/A'}',
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRandomStat,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
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
