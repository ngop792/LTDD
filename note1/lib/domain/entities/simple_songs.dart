class SimpleSong {
  final String id; // 🔹 cần có để xóa bài hoặc đồng bộ
  final String title;
  final String artist;
  final num duration;
  final String imageUrl;
  final String audioUrl;

  SimpleSong({
    this.id = '',
    required this.title,
    required this.artist,
    required this.duration,
    this.imageUrl = '',
    this.audioUrl = '',
  });

  factory SimpleSong.fromJson(Map<String, dynamic> json) {
    print('📥 Song JSON: $json'); // debug

    return SimpleSong(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      artist: json['artist'] ?? json['singer'] ?? '',
      duration: json['duration'] ?? 0,
      // ✅ hỗ trợ cả camelCase và snake_case
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      audioUrl:
          json['audioUrl'] ?? json['audio_url'] ?? json['file_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'artist': artist,
      'duration': duration,
      'image_url': imageUrl,
      'audio_url': audioUrl,
    };
  }
}
