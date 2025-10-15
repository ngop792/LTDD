import 'package:note1/domain/entities/simple_songs.dart';

class Playlist {
  final String id;
  final String name;
  final List<SimpleSong> songs;

  Playlist({required this.id, required this.name, this.songs = const []});
}
