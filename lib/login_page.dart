import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Import animate_do
import 'package:mongo_dart/mongo_dart.dart'
    as mongo; // Thêm alias để tránh xung đột
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'main.dart'; // Import MainScreen để điều hướng

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  late mongo.Db _db; // Sử dụng alias mongo
  late mongo.DbCollection _usersCollection;
  bool _isConnected = false; // Biến để kiểm tra trạng thái kết nối
  String? _connectionError; // Biến để lưu thông báo lỗi kết nối

  @override
  void initState() {
    super.initState();
    _connectToMongoDB();
  }

  // Kết nối đến MongoDB Atlas
  Future<void> _connectToMongoDB() async {
    try {
      // Bước 1: Tải file .env và lấy chuỗi kết nối
      await dotenv.load(fileName: ".env");
      final mongoUrl = dotenv.env['MONGO_URL'];
      if (mongoUrl == null || mongoUrl.isEmpty) {
        throw Exception('MONGO_URL không được tìm thấy trong file .env');
      }
      debugPrint('MONGO_URL: $mongoUrl'); // In chuỗi kết nối để kiểm tra

      // Bước 2: Khởi tạo kết nối với MongoDB Atlas
      _db = await mongo.Db.create(mongoUrl);
      await _db.open(); // Bỏ tham số connectionTimeout

      // Bước 3: Lấy collection 'users' từ database HermitHome
      _usersCollection = _db.collection('users');

      setState(() {
        _isConnected = true; // Đánh dấu kết nối thành công
      });
      debugPrint('Kết nối MongoDB thành công');
    } catch (e) {
      setState(() {
        _isConnected = false; // Đánh dấu kết nối thất bại
        _connectionError = e.toString(); // Lưu thông báo lỗi
      });
      debugPrint('Lỗi khi kết nối MongoDB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể kết nối đến cơ sở dữ liệu: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  // Hàm kiểm tra đăng nhập với MongoDB và trả về userId
  // Future<String?> _checkCredentials(String email, String password) async {
  //   if (!_isConnected) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text(
  //                 'Không thể kết nối đến cơ sở dữ liệu: $_connectionError')),
  //       );
  //     }
  //     return null;
  //   }

  //   try {
  //     final user = await _usersCollection
  //         .findOne(mongo.where.eq('email', email).eq('password', password));
  //     if (user != null) {
  //       return user['_id'].toString(); // Trả về userId dưới dạng chuỗi
  //     }
  //     return null; // Trả về null nếu không tìm thấy tài khoản
  //   } catch (e) {
  //     debugPrint('Lỗi khi kiểm tra thông tin đăng nhập: $e');
  //     return null;
  //   }
  // }

  Future<String?> _checkCredentials(String email, String password) async {
    if (!_isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Không thể kết nối đến cơ sở dữ liệu: $_connectionError')),
        );
      }
      return null;
    }

    try {
      final user = await _usersCollection
          .findOne(mongo.where.eq('email', email).eq('password', password));
      if (user != null) {
        final userId = user['_id'].toHexString();
        debugPrint('userId (Hex): $userId'); // Kiểm tra giá trị
        return userId;
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra thông tin đăng nhập: $e');
      return null;
    }
  }

  // Hàm xử lý khi nhấn nút đăng nhập
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? userId = await _checkCredentials(_email, _password);
      if (userId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(userId: userId),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email hoặc mật khẩu không đúng!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.cyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo với hiệu ứng FadeIn
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Image.asset(
                        'assets/icon/Logov3.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tiêu đề với hiệu ứng FadeIn
                    // FadeInDown(
                    //   duration: const Duration(milliseconds: 800),
                    //   delay: const Duration(milliseconds: 200),
                    //   child: const Text(
                    //     'Hermit Home',
                    //     style: TextStyle(
                    //       fontSize: 36,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.white,
                    //       shadows: [
                    //         Shadow(
                    //           color: Colors.black26,
                    //           blurRadius: 10,
                    //           offset: Offset(0, 2),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 40),

                    // Trường nhập email với hiệu ứng SlideInUp
                    SlideInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.blueAccent,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Trường nhập mật khẩu với hiệu ứng SlideInUp
                    SlideInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Mật khẩu',
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.blueAccent,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải dài ít nhất 6 ký tự';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Nút đăng nhập với hiệu ứng SlideInUp
                    SlideInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.cyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 15,
                            ),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Đăng Nhập',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Liên kết đăng ký với hiệu ứng SlideInUp
                    SlideInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 700),
                      child: TextButton(
                        onPressed: () {
                          debugPrint('Chuyển sang trang đăng ký');
                        },
                        child: const Text(
                          'Chưa có tài khoản? Đăng ký ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
