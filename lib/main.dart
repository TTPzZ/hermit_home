import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const HermitHomeApp());
}

class HermitHomeApp extends StatelessWidget {
  const HermitHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hermit Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Mặc định chọn tab Home (giữa)

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const StatsScreen(),
    const HomeScreen(),
    const SettingsScreen(),
  ];

  // Danh sách biểu tượng
  final List<IconData> _icons = [Icons.bar_chart, Icons.home, Icons.settings];

  // Danh sách nhãn
  final List<String> _labels = ['Stats', 'Home', 'Settings'];

  // Khi nhấn vào tab, cập nhật tab được chọn
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
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
            title: const Text('Hermit Home'),
            // cái chuông thôi
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.notifications, color: Colors.white),
            //     onPressed: () {
            //       // Xử lý thông báo (có thể thêm sau)
            //     },
            //   ),
            // ],
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 4,
            bottom: 16,
          ),
          child: Container(
            height: 71, // Giữ nguyên độ cao 71
            decoration: BoxDecoration(
              color: Colors.white, // Đổi màu nền thành trắng
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6), // Bóng mạnh hơn và đổ xuống dưới
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
                    padding: EdgeInsets.all(isSelected ? 6 : 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          isSelected
                              ? const LinearGradient(
                                colors: [Colors.blueAccent, Colors.cyan],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                              : null,
                      boxShadow:
                          isSelected
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
