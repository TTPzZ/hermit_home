import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../login_page.dart'; // Import LoginPage để điều hướng khi đăng xuất

class SettingsScreen extends StatefulWidget {
  final String userId; // Nhận userId từ MainScreen
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;
  final double minLight;
  final double maxLight;
  final bool isLoading; // Thêm trạng thái loading

  const SettingsScreen({
    super.key,
    required this.userId,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
    required this.minLight,
    required this.maxLight,
    required this.isLoading,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _minHumidityController;
  late TextEditingController _maxHumidityController;
  late TextEditingController _minLightController;
  late TextEditingController _maxLightController;

  late mongo.Db _db;
  late mongo.DbCollection _thresholdsCollection;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với giá trị từ MainScreen
    _minTempController =
        TextEditingController(text: widget.minTemperature.toStringAsFixed(1));
    _maxTempController =
        TextEditingController(text: widget.maxTemperature.toStringAsFixed(1));
    _minHumidityController =
        TextEditingController(text: widget.minHumidity.toStringAsFixed(1));
    _maxHumidityController =
        TextEditingController(text: widget.maxHumidity.toStringAsFixed(1));
    _minLightController =
        TextEditingController(text: widget.minLight.toStringAsFixed(1));
    _maxLightController =
        TextEditingController(text: widget.maxLight.toStringAsFixed(1));

    _connectToMongoDB();
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật lại giá trị của các controller khi widget được rebuild với dữ liệu mới
    _minTempController.text = widget.minTemperature.toStringAsFixed(1);
    _maxTempController.text = widget.maxTemperature.toStringAsFixed(1);
    _minHumidityController.text = widget.minHumidity.toStringAsFixed(1);
    _maxHumidityController.text = widget.maxHumidity.toStringAsFixed(1);
    _minLightController.text = widget.minLight.toStringAsFixed(1);
    _maxLightController.text = widget.maxLight.toStringAsFixed(1);
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

  Future<void> _saveThresholds() async {
    try {
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

      await _thresholdsCollection.updateOne(
        mongo.where.eq('userId', widget.userId),
        {'\$set': thresholds},
        upsert: true,
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
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cài đặt ngưỡng thông số',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection('Nhiệt độ (°C)', Icons.thermostat, [
                      _buildInputField('Tối thiểu', _minTempController),
                      const SizedBox(width: 10),
                      _buildInputField('Tối đa', _maxTempController),
                    ]),
                    _buildSection('Độ ẩm (%)', Icons.water_drop, [
                      _buildInputField('Tối thiểu', _minHumidityController),
                      const SizedBox(width: 10),
                      _buildInputField('Tối đa', _maxHumidityController),
                    ]),
                    _buildSection('Ánh sáng (lux)', Icons.wb_sunny, [
                      _buildInputField('Tối thiểu', _minLightController),
                      const SizedBox(width: 10),
                      _buildInputField('Tối đa', _maxLightController),
                    ]),
                    const SizedBox(height: 40),
                    Center(
                      child: GestureDetector(
                        onTap: _saveThresholds,
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
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã đăng xuất!')),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false,
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
