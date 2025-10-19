import 'dart:convert';
import 'package:http/http.dart' as http;

class SongService {
  final String baseUrl =
      'http://127.0.0.1:8000/api'; // đổi IP nếu test trên điện thoại thật

  Future<List<dynamic>> fetchSongs() async {
    final response = await http.get(Uri.parse('$baseUrl/songs'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['songs'];
    } else {
      throw Exception('Failed to load songs');
    }
  }
}
