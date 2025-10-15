import 'dart:convert';
import 'package:http/http.dart' as http;

class SongService {
  final String baseUrl =
      'http://127.0.0.1:8000/api/songs'; // ⚠️ Địa chỉ Laravel

  Future<List<dynamic>> fetchSongs() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi: ${response.statusCode}');
    }
  }
}
