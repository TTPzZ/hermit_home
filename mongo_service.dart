import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static final String uri =
      "mongodb+srv://phucthan299:8EPAi39e0YY0LGKu@ttp.v5nzx.mongodb.net/?retryWrites=true&w=majority&appName=TTP";
  static late Db db;
  static late DbCollection collection;

  static Future<void> connect() async {
    db = await Db.create(uri);
    await db.open();
    collection = db.collection('sensor_data'); // Tên collection
    print("✅ Kết nối MongoDB thành công!");
  }

  static Future<void> insertData(Map<String, dynamic> data) async {
    await collection.insertOne(data);
    print("📝 Dữ liệu đã được lưu vào MongoDB!");
  }
}
