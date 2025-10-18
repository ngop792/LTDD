import 'package:note1/domain/entities/simple_songs.dart';

class Playlist {
  final String id;
  final String name;
  final String author;
  final List<SimpleSong> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.author,
    this.songs = const [],
  });
}
