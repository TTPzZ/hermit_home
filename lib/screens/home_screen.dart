import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  final String userId; // Nhận userId từ MainScreen
  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late mongo.Db _db;
  late mongo.DbCollection _statsCollection;
  double temperature = 0.0;
  double humidity = 0.0;
  double light = 0.0;
  bool _isLoading = true;
  late Timer _timer;

  bool isTemperatureSensorEnabled = true;
  bool isHumiditySensorEnabled = true;
  bool isLightSensorEnabled = true;

  @override
  void initState() {
    super.initState();
    debugPrint('HomeScreen userId: ${widget.userId}'); // In userId để kiểm tra

    // Sử dụng Future để đảm bảo kết nối MongoDB hoàn tất trước khi lấy dữ liệu
    _initialize().then((_) {
      _fetchCurrentStats(); // Lấy dữ liệu ngay sau khi kết nối thành công
      // Cập nhật dữ liệu mỗi 5 phút
      _timer = Timer.periodic(Duration(minutes: 5), (timer) {
        _fetchCurrentStats();
      });
    });
  }

  Future<void> _initialize() async {
    await _connectToMongoDB();
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
      _statsCollection = _db.collection('current_stats');
    } catch (e) {
      debugPrint('Lỗi khi kết nối MongoDB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể kết nối đến cơ sở dữ liệu: $e')),
        );
      }
    }
  }

  Future<void> _fetchCurrentStats() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final stats = await _statsCollection
          .findOne(mongo.where.eq('userId', widget.userId));
      setState(() {
        if (stats != null) {
          temperature = (stats['temperature'] as num?)?.toDouble() ?? 0.0;
          humidity = (stats['humidity'] as num?)?.toDouble() ?? 0.0;
          light = (stats['light'] as num?)?.toDouble() ?? 0.0;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi khi lấy dữ liệu hiện tại: $e');
      setState(() {
        temperature = 0.0;
        humidity = 0.0;
        light = 0.0;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
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
                      borderRadius: BorderRadius.circular(40),
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
                            isTemperatureSensorEnabled =
                                !isTemperatureSensorEnabled;
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
