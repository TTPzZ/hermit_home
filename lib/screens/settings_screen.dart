import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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

  @override
  void dispose() {
    _minTempController.dispose();
    _maxTempController.dispose();
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    _minLightController.dispose();
    _maxLightController.dispose();
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu cài đặt!')),
                    );
                  },
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
