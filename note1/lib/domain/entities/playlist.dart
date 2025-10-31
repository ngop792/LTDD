import 'simple_songs.dart';

class Playlist {
  final String id;
  final String name;
  final String author;
  final String? userId;
  final bool isPrivate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SimpleSong> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.author,
    this.userId,
    this.isPrivate = false,
    this.createdAt,
    this.updatedAt,
    this.songs = const [],
  });

  /// Tạo từ JSON (Laravel API)
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Playlist',
      author: json['author'] ?? 'Không rõ',
      userId: json['user_id'],
      isPrivate: json['is_private'] == 1 || json['is_private'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      songs: json['songs'] != null
          ? List<SimpleSong>.from(
              (json['songs'] as List).map((s) => SimpleSong.fromJson(s)),
            )
          : [],
    );
  }

  /// Chuyển về JSON (gửi lên server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'user_id': userId,
      'is_private': isPrivate ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'songs': songs.map((s) => s.toJson()).toList(),
    };
  }
}
