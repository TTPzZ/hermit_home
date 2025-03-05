import 'dart:async';
import 'dart:math';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpdateStatsService {
  late mongo.Db _db;
  late mongo.DbCollection _statsCollection;
  bool _isInitialized = false;

  UpdateStatsService();

  // Khởi tạo kết nối MongoDB
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await dotenv.load(fileName: ".env");
      final mongoUrl = dotenv.env['MONGO_URL'];
      if (mongoUrl == null || mongoUrl.isEmpty) {
        throw Exception('MONGO_URL không được tìm thấy trong file .env');
      }
      _db = await mongo.Db.create(mongoUrl);
      await _db.open();
      _statsCollection = _db.collection('current_stats');
      _isInitialized = true;
    } catch (e) {
      print('Lỗi khi khởi tạo UpdateStatsService: $e');
      rethrow;
    }
  }

  // Mô phỏng cập nhật dữ liệu ngẫu nhiên mỗi 5 phút
  void startUpdatingStats(String userId) async {
    await initialize();
    Timer.periodic(Duration(minutes: 5), (timer) async {
      try {
        final random = Random();
        final newStats = {
          'userId': userId,
          'temperature':
              25 + random.nextInt(10), // Nhiệt độ ngẫu nhiên từ 25-35
          'humidity': 60 + random.nextInt(20), // Độ ẩm ngẫu nhiên từ 60-80
          'light': 200 + random.nextInt(300), // Ánh sáng ngẫu nhiên từ 200-500
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        };

        // Cập nhật bản ghi duy nhất trong collection current_stats
        await _statsCollection.updateOne(
          mongo.where.eq('userId', userId),
          {
            '\$set': newStats,
          },
          upsert: true, // Nếu không có bản ghi, chèn mới
        );
        print('Đã cập nhật dữ liệu: $newStats');
      } catch (e) {
        print('Lỗi khi cập nhật dữ liệu stats: $e');
      }
    });
  }

  // Đóng kết nối khi không cần thiết
  void dispose() {
    if (_isInitialized) {
      _db.close();
      _isInitialized = false;
    }
  }
}
