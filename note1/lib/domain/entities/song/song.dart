import 'package:supabase_flutter/supabase_flutter.dart';

class SongEntity {
  final String title;
  final String artist;
  final num duration;
  final DateTime releaseDate;

  SongEntity({
    required this.title,
    required this.artist,
    required this.duration,
    required this.releaseDate,
  });

  static fromJson(Map<String, dynamic> e) {}
}
