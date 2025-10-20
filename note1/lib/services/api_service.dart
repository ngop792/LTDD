import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  /// ⚙️ Cấu hình IP
  /// Emulator: http://10.0.2.2:8000/api
  /// Device thật: http://192.168.x.x:8000/api
  static const String baseUrl = "http://192.168.0.105:8000/api";

  /// Upload file từ điện thoại
  static Future<bool> uploadSong(String title, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print("❌ File không tồn tại: $filePath");
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/songs/upload"),
      );
      request.fields['title'] = title;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      print("Response status: ${response.statusCode}");
      print("Response body: $respStr");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi uploadSong: $e");
      return false;
    }
  }

  /// Upload file từ web
  static Future<bool> uploadSongWeb(
    String title,
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      var uri = Uri.parse("$baseUrl/songs/upload");
      var request = http.MultipartRequest('POST', uri);
      request.fields['title'] = title;

      if (fileBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
            contentType: MediaType('audio', 'mpeg'),
          ),
        );
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("Response status: ${response.statusCode}");
      print("Response body: $respStr");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi uploadSongWeb: $e");
      return false;
    }
  }

  /// Lấy danh sách nhạc
  static Future<List<dynamic>> getSongs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/songs"));
      print("GET /songs: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['songs'] ?? [];
      }
      return [];
    } catch (e) {
      print("❌ Lỗi getSongs: $e");
      return [];
    }
  }

  /// Test server
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/ping"));
      print("Ping: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi testConnection: $e");
      return false;
    }
  }
}
