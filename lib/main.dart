import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'login_page.dart'; // Import LoginPage
import 'services/update_stats_service.dart'; // Import UpdateStatsService
import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(const HermitHomeApp());
}

class HermitHomeApp extends StatelessWidget {
  const HermitHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HermitHome',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          showUnselectedLabels: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String userId;
  const MainScreen({super.key, required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  late List<Widget> _screens;
  late UpdateStatsService _updateStatsService;

  // Dữ liệu cho HomeScreen (current_stats)
  double temperature = 0.0;
  double humidity = 0.0;
  double light = 0.0;
  bool _isStatsLoading = true;

  // Dữ liệu cho SettingsScreen (thresholds)
  double minTemperature = 20.0;
  double maxTemperature = 35.0;
  double minHumidity = 50.0;
  double maxHumidity = 80.0;
  double minLight = 200.0;
  double maxLight = 500.0;
  bool _isThresholdsLoading = true;

  late Timer _timer;
  late mongo.Db _db;
  late mongo.DbCollection _statsCollection;
  late mongo.DbCollection _thresholdsCollection;

  final List<IconData> _icons = [Icons.bar_chart, Icons.home, Icons.settings];
  final List<String> _labels = ['Stats', 'Home', 'Settings'];

  @override
  void initState() {
    super.initState();
    _updateStatsService = UpdateStatsService();

    // Khởi tạo danh sách screens với trạng thái loading ban đầu
    _screens = [
      StatsScreen(userId: widget.userId),
      HomeScreen(
        userId: widget.userId,
        temperature: temperature,
        humidity: humidity,
        light: light,
        isLoading: _isStatsLoading,
      ),
      SettingsScreen(
        userId: widget.userId,
        minTemperature: minTemperature,
        maxTemperature: maxTemperature,
        minHumidity: minHumidity,
        maxHumidity: maxHumidity,
        minLight: minLight,
        maxLight: maxLight,
        isLoading: _isThresholdsLoading,
      ),
    ];

    // Kết nối và lấy dữ liệu
    _initialize().then((_) {
      _fetchData();
      _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
        _fetchData();
      });
    });
  }

  Future<void> _initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      final mongoUrl = dotenv.env['MONGO_URL'];
      if (mongoUrl == null || mongoUrl.isEmpty) {
        throw Exception('MONGO_URL không được tìm thấy trong file .env');
      }
      _db = await mongo.Db.create(mongoUrl);
      await _db.open();
      _statsCollection = _db.collection('current_stats');
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

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchCurrentStats(),
      _fetchThresholds(),
    ]);
  }

  Future<void> _fetchCurrentStats() async {
    try {
      setState(() => _isStatsLoading = true);
      final stats = await _statsCollection
          .findOne(mongo.where.eq('userId', widget.userId));
      setState(() {
        if (stats != null) {
          temperature = (stats['temperature'] as num?)?.toDouble() ?? 0.0;
          humidity = (stats['humidity'] as num?)?.toDouble() ?? 0.0;
          light = (stats['light'] as num?)?.toDouble() ?? 0.0;
        } else {
          temperature = 0.0;
          humidity = 0.0;
          light = 0.0;
        }
        _isStatsLoading = false;
        _updateScreens();
      });
    } catch (e) {
      debugPrint('Lỗi khi lấy current_stats: $e');
      setState(() {
        temperature = 0.0;
        humidity = 0.0;
        light = 0.0;
        _isStatsLoading = false;
        _updateScreens();
      });
    }
  }

  Future<void> _fetchThresholds() async {
    try {
      setState(() => _isThresholdsLoading = true);
      final thresholds = await _thresholdsCollection
          .findOne(mongo.where.eq('userId', widget.userId));
      setState(() {
        if (thresholds != null) {
          minTemperature =
              (thresholds['minTemperature'] as num?)?.toDouble() ?? 20.0;
          maxTemperature =
              (thresholds['maxTemperature'] as num?)?.toDouble() ?? 35.0;
          minHumidity = (thresholds['minHumidity'] as num?)?.toDouble() ?? 50.0;
          maxHumidity = (thresholds['maxHumidity'] as num?)?.toDouble() ?? 80.0;
          minLight = (thresholds['minLight'] as num?)?.toDouble() ?? 200.0;
          maxLight = (thresholds['maxLight'] as num?)?.toDouble() ?? 500.0;
        }
        _isThresholdsLoading = false;
        _updateScreens();
      });
    } catch (e) {
      debugPrint('Lỗi khi lấy thresholds: $e');
      setState(() {
        minTemperature = 20.0;
        maxTemperature = 35.0;
        minHumidity = 50.0;
        maxHumidity = 80.0;
        minLight = 200.0;
        maxLight = 500.0;
        _isThresholdsLoading = false;
        _updateScreens();
      });
    }
  }

  void _updateScreens() {
    _screens = [
      StatsScreen(userId: widget.userId),
      HomeScreen(
        userId: widget.userId,
        temperature: temperature,
        humidity: humidity,
        light: light,
        isLoading: _isStatsLoading,
      ),
      SettingsScreen(
        userId: widget.userId,
        minTemperature: minTemperature,
        maxTemperature: maxTemperature,
        minHumidity: minHumidity,
        maxHumidity: maxHumidity,
        minLight: minLight,
        maxLight: maxLight,
        isLoading: _isThresholdsLoading,
      ),
    ];
  }

  @override
  void dispose() {
    _timer.cancel();
    _db.close();
    _updateStatsService.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 80,
            leading: Padding(
              padding: const EdgeInsets.only(left: 26.0, bottom: 4),
              child: GestureDetector(
                onTap: () {
                  _fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Đã cập nhật dữ liệu mới nhất!')),
                  );
                },
                child: Transform.scale(
                  scale: 2.5,
                  child: Image.asset(
                    'assets/icon/Logov3.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    'Hermit Home',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 14),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 3,
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              items: List.generate(_icons.length, (index) {
                final isSelected = _selectedIndex == index;
                return BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isSelected ? 4 : 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Colors.blueAccent, Colors.cyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _icons[index],
                      size: isSelected ? 28 : 22,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  label: _labels[index],
                );
              }),
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ),
      ),
    );
  }
}
