import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<dynamic>> fetchData() async {
    final response =
        await http.get(Uri.parse('http://<IP_SERVER>:5000/get-data'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
