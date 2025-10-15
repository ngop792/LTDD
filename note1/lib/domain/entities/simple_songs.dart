// lib/domain/entities/simple_song.dart

class SimpleSong {
  final String title;
  final String artist;
  final num duration;
  final String imageUrl; // ⭐️ THÊM TRƯỜNG NÀY

  SimpleSong({
    required this.title,
    required this.artist,
    required this.duration,
    required this.imageUrl, // ⭐️ VÀ THÊM VÀO CONSTRUCTOR
  });
}
