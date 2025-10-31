import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:note1/services/api_constants.dart';

class SongService {
  /// Lấy danh sách tất cả bài hát
  Future<List<dynamic>> fetchSongs() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/songs');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['songs'] ?? [];
    } else {
      throw Exception('Failed to load songs: ${response.statusCode}');
    }
  }

  /// Lấy danh sách playlist
  Future<List<dynamic>> fetchPlaylists() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/playlists');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['playlists'] ?? [];
    } else {
      throw Exception('Failed to load playlists: ${response.statusCode}');
    }
  }

  /// ✅ Lấy bài trong một playlist (đã sửa)
  Future<List<dynamic>> fetchSongsInPlaylist(String playlistId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/playlists/$playlistId/songs',
    );
    final response = await http.get(url);

    print('📡 GET $url');
    print('📥 Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['songs'] != null) {
        return List<Map<String, dynamic>>.from(data['songs']);
      }
    }
    return [];
  }

  /// Thêm bài vào playlist
  Future<bool> addSongToPlaylist({
    required String playlistId,
    required Map<String, dynamic> songData,
  }) async {
    if (playlistId.trim().isEmpty) {
      print('⚠️ Playlist ID rỗng, không thể thêm bài');
      return false;
    }

    if (!songData.containsKey('song_id') ||
        songData['song_id'].toString().isEmpty) {
      print('⚠️ Dữ liệu bài hát không hợp lệ: $songData');
      return false;
    }

    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/playlists/$playlistId/add-song',
      );

      print('📤 Gửi POST request tới: $url');
      print('📄 Body: ${json.encode(songData)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(songData),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'Song added successfully') {
          print('✅ Thêm bài hát thành công!');
          return true;
        } else {
          print('❌ API trả về lỗi: ${data['message'] ?? 'Không rõ lỗi'}');
          return false;
        }
      } else {
        print('❌ Thêm bài thất bại: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi khi thêm bài: $e');
      return false;
    }
  }

  /// Xóa bài khỏi playlist
  Future<bool> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    if (playlistId.trim().isEmpty || songId.trim().isEmpty) {
      print('⚠️ Playlist ID hoặc Song ID rỗng');
      return false;
    }

    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/playlists/$playlistId/songs/$songId',
      );
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Xóa bài thành công!');
        return true;
      } else {
        print('❌ Xóa bài thất bại: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi khi xóa bài: $e');
      return false;
    }
  }

  /// Xóa playlist
  Future<bool> deletePlaylist(String playlistId) async {
    if (playlistId.trim().isEmpty) {
      print('⚠️ Playlist ID rỗng, không thể xóa');
      return false;
    }

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/playlists/$playlistId');
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Xóa playlist thành công!');
        return true;
      } else {
        print(
          '❌ Xóa playlist thất bại: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Lỗi khi xóa playlist: $e');
      return false;
    }
  }
}
