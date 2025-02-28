import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Giá trị khởi tạo cho nhiệt độ, độ ẩm, ánh sáng
  double temperature = 28.0;
  double humidity = 65.0;
  double light = 300.0;

  // Trạng thái bật/tắt riêng cho từng cảm biến
  bool isTemperatureSensorEnabled = true;
  bool isHumiditySensorEnabled = true;
  bool isLightSensorEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Nửa trên: Camera (Placeholder)
        Container(
          height:
              MediaQuery.of(context).size.height * 0.5, // Chiếm nửa màn hình
          color: Colors.grey[300],
          child: const Center(
            child: Text(
              'Camera Placeholder\n(Quay vào bể)',
              style: TextStyle(fontSize: 20, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Nửa dưới: Điều chỉnh nhiệt độ, độ ẩm, ánh sáng
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dòng 1: Nhiệt độ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nhiệt độ:', style: TextStyle(fontSize: 18)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              isTemperatureSensorEnabled
                                  ? () {
                                    setState(() {
                                      temperature -= 0.5; // Giảm 0.5°C
                                    });
                                  }
                                  : null, // Vô hiệu hóa nếu cảm biến nhiệt độ tắt
                        ),
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed:
                              isTemperatureSensorEnabled
                                  ? () {
                                    setState(() {
                                      temperature += 0.5; // Tăng 0.5°C
                                    });
                                  }
                                  : null, // Vô hiệu hóa nếu cảm biến nhiệt độ tắt
                        ),
                        const SizedBox(width: 10),
                        // Nút bật/tắt cảm biến nhiệt độ
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isTemperatureSensorEnabled =
                                  !isTemperatureSensorEnabled;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isTemperatureSensorEnabled
                                    ? Colors.red
                                    : Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                          ),
                          child: Text(
                            isTemperatureSensorEnabled ? 'Tắt' : 'Bật',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Dòng 2: Độ ẩm
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Độ ẩm:', style: TextStyle(fontSize: 18)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              isHumiditySensorEnabled
                                  ? () {
                                    setState(() {
                                      humidity -= 1.0; // Giảm 1%
                                    });
                                  }
                                  : null, // Vô hiệu hóa nếu cảm biến độ ẩm tắt
                        ),
                        Text(
                          '${humidity.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed:
                              isHumiditySensorEnabled
                                  ? () {
                                    setState(() {
                                      humidity += 1.0; // Tăng 1%
                                    });
                                  }
                                  : null, // Vô hiệu hóa nếu cảm biến độ ẩm tắt
                        ),
                        const SizedBox(width: 10),
                        // Nút bật/tắt cảm biến độ ẩm
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isHumiditySensorEnabled =
                                  !isHumiditySensorEnabled;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isHumiditySensorEnabled
                                    ? Colors.red
                                    : Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                          ),
                          child: Text(
                            isHumiditySensorEnabled ? 'Tắt' : 'Bật',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Dòng 3: Ánh sáng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ánh sáng:', style: TextStyle(fontSize: 18)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              isLightSensorEnabled
                                  ? () {
                                    setState(() {
                                      light -= 10.0; // Giảm 10 lux
                                    });
                                  }
                                  : null, // Vô hiệu hóa nếu cảm biến ánh sáng tắt
                        ),
                        Text(
                          '${light.toStringAsFixed(0)} lux',
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed:
                              isLightSensorEnabled
                                  ? () {
                                    setState(() {
                                      light += 10.0; // Tăng 10 lux
                                    });
                                  }
                                  : null, // Vô hiệu hóa nếu cảm biến ánh sáng tắt
                        ),
                        const SizedBox(width: 10),
                        // Nút bật/tắt cảm biến ánh sáng
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLightSensorEnabled = !isLightSensorEnabled;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isLightSensorEnabled
                                    ? Colors.red
                                    : Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                          ),
                          child: Text(
                            isLightSensorEnabled ? 'Tắt' : 'Bật',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
