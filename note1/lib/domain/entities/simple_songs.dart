class SimpleSong {
  final String title;
  final String artist;
  final num duration;
  final String imageUrl;
  final String audioUrl;

  SimpleSong({
    required this.title,
    required this.artist,
    required this.duration,
    required this.imageUrl,
    required this.audioUrl,
  });

  factory SimpleSong.fromJson(Map<String, dynamic> json) {
    return SimpleSong(
      title: json['title'] ?? 'Unknown title',
      artist: json['artist'] ?? 'Unknown artist',
      duration: json['duration'] ?? 0,
      imageUrl: json['image_url'] ?? '', // có thể rỗng nếu API chưa có ảnh
      audioUrl: json['url'] ?? '', // ✅ map đúng trường URL từ Laravel
    );
  }
}
