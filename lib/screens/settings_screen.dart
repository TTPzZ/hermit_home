import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../login_page.dart'; // Import LoginPage để điều hướng khi đăng xuất

class SettingsScreen extends StatefulWidget {
  final String userId; // Nhận userId từ MainScreen
  const SettingsScreen({super.key, required this.userId});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controller cho các TextField
  final TextEditingController _minTempController = TextEditingController(
    text: '20.0',
  );
  final TextEditingController _maxTempController = TextEditingController(
    text: '35.0',
  );
  final TextEditingController _minHumidityController = TextEditingController(
    text: '50.0',
  );
  final TextEditingController _maxHumidityController = TextEditingController(
    text: '80.0',
  );
  final TextEditingController _minLightController = TextEditingController(
    text: '200.0',
  );
  final TextEditingController _maxLightController = TextEditingController(
    text: '500.0',
  );

  late mongo.Db _db;
  late mongo.DbCollection _thresholdsCollection;

  @override
  void initState() {
    super.initState();
    _connectToMongoDB();
    _loadThresholds(); // Tải ngưỡng hiện tại từ MongoDB
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
      _thresholdsCollection = _db.collection('thresholds');
    } catch (e) {
      debugPrint('Lỗi khi kết nối MongoDB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể kết nối đến cơ sở dữ liệu: $e')),
        );
      }
    }
  }

  Future<void> _loadThresholds() async {
    try {
      final thresholds = await _thresholdsCollection
          .findOne(mongo.where.eq('userId', widget.userId));
      if (thresholds != null) {
        setState(() {
          _minTempController.text =
              thresholds['minTemperature']?.toString() ?? '20.0';
          _maxTempController.text =
              thresholds['maxTemperature']?.toString() ?? '35.0';
          _minHumidityController.text =
              thresholds['minHumidity']?.toString() ?? '50.0';
          _maxHumidityController.text =
              thresholds['maxHumidity']?.toString() ?? '80.0';
          _minLightController.text =
              thresholds['minLight']?.toString() ?? '200.0';
          _maxLightController.text =
              thresholds['maxLight']?.toString() ?? '500.0';
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi tải ngưỡng từ MongoDB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải ngưỡng: $e')),
        );
      }
    }
  }

  Future<void> _saveThresholds() async {
    try {
      // Lấy giá trị từ các TextField và chuyển thành double
      final thresholds = {
        'userId': widget.userId,
        'minTemperature': double.tryParse(_minTempController.text) ?? 20.0,
        'maxTemperature': double.tryParse(_maxTempController.text) ?? 35.0,
        'minHumidity': double.tryParse(_minHumidityController.text) ?? 50.0,
        'maxHumidity': double.tryParse(_maxHumidityController.text) ?? 80.0,
        'minLight': double.tryParse(_minLightController.text) ?? 200.0,
        'maxLight': double.tryParse(_maxLightController.text) ?? 500.0,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };

      // Cập nhật ngưỡng vào collection thresholds
      await _thresholdsCollection.updateOne(
        mongo.where.eq('userId', widget.userId),
        {
          '\$set': thresholds,
        },
        upsert: true, // Nếu không có bản ghi, chèn mới
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu cài đặt ngưỡng thành công!')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi lưu ngưỡng vào MongoDB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu ngưỡng: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _minTempController.dispose();
    _maxTempController.dispose();
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    _minLightController.dispose();
    _maxLightController.dispose();
    _db.close();
    super.dispose();
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> inputFields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 26),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(children: inputFields),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              const Text(
                'Cài đặt ngưỡng thông số',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 24),

              // Nhiệt độ
              _buildSection('Nhiệt độ (°C)', Icons.thermostat, [
                _buildInputField('Tối thiểu', _minTempController),
                const SizedBox(width: 10),
                _buildInputField('Tối đa', _maxTempController),
              ]),

              // Độ ẩm
              _buildSection('Độ ẩm (%)', Icons.water_drop, [
                _buildInputField('Tối thiểu', _minHumidityController),
                const SizedBox(width: 10),
                _buildInputField('Tối đa', _maxHumidityController),
              ]),

              // Ánh sáng
              _buildSection('Ánh sáng (lux)', Icons.wb_sunny, [
                _buildInputField('Tối thiểu', _minLightController),
                const SizedBox(width: 10),
                _buildInputField('Tối đa', _maxLightController),
              ]),

              const SizedBox(height: 40),

              // Nút Lưu Cài Đặt
              Center(
                child: GestureDetector(
                  onTap: _saveThresholds, // Gọi hàm lưu ngưỡng
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Lưu cài đặt',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Nút Đăng Xuất
              Center(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã đăng xuất!')),
                    );
                    // Điều hướng về LoginPage và xóa stack điều hướng
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false, // Xóa toàn bộ stack
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.redAccent, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Đăng Xuất',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
