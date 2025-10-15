import 'package:note1/domain/entities/song/song.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SongModel {
  String? title;
  String? artist;
  num? duration;
  DateTime? releaseDate;

  SongModel({
    required this.title,
    required this.artist,
    required this.duration,
    required this.releaseDate,
  });

  factory SongModel.fromJson(Map<String, dynamic> data) {
    return SongModel(
      title: data['title'] as String?,
      artist: data['artist'] as String?,
      duration: data['duration'] as num?,
      releaseDate: data['release_date'] != null
          ? DateTime.parse(data['release_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'duration': duration,
      'release_date': releaseDate?.toIso8601String(),
    };
  }
}

extension SongModelX on SongModel {
  SongEntity toEntity() {
    return SongEntity(
      title: title ?? '',
      artist: artist ?? '',
      duration: duration ?? 0,
      releaseDate: releaseDate ?? DateTime.now(),
    );
  }
}
