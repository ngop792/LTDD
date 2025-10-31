import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:note1/services/api_constants.dart';
import 'package:note1/domain/entities/playlist.dart';

class PlaylistService {
  static final String _baseUrl = ApiConstants.baseUrl;

  /// 🟢 Lấy danh sách playlist theo user_id
  static Future<List<Playlist>> fetchPlaylists({required String userId}) async {
    try {
      final uri = Uri.parse('$_baseUrl/playlists?user_id=$userId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> list = data['data'];
          return list.map((item) => Playlist.fromJson(item)).toList();
        } else {
          throw Exception(data['message'] ?? 'Lỗi không xác định');
        }
      } else {
        throw Exception('Lỗi tải playlist: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // giữ nguyên lỗi để xử lý ở UI
    }
  }

  /// 🟢 Tạo playlist mới
  static Future<Playlist?> createPlaylist({
    required String name,
    required String author,
    required String userId,
    required bool isPrivate,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/playlists');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'author': author,
          'user_id': userId,
          'is_private': isPrivate,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Playlist.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Lỗi tạo playlist');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Lỗi tạo playlist');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 🟢 Xóa playlist
  static Future<void> deletePlaylist(String playlistId) async {
    try {
      final uri = Uri.parse('$_baseUrl/playlists/$playlistId');
      final response = await http.delete(uri);

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể xóa playlist');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 🟡 Cập nhật playlist
  static Future<Playlist?> updatePlaylist({
    required String playlistId,
    String? name,
    String? author,
    bool? isPrivate,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/playlists/$playlistId');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (name != null) 'name': name,
          if (author != null) 'author': author,
          if (isPrivate != null) 'is_private': isPrivate,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Playlist.fromJson(data['data']);
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Lỗi cập nhật playlist');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// 🟣 Lấy thông tin 1 playlist cụ thể
  static Future<Playlist?> getPlaylistDetail(String playlistId) async {
    try {
      final uri = Uri.parse('$_baseUrl/playlists/$playlistId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Playlist.fromJson(data['data']);
        }
      } else {
        throw Exception('Lỗi tải playlist chi tiết');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
