import 'package:flutter/material.dart';
import 'package:get/get.dart'; // ✅ thêm để dùng .tr
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/song_player/pages/song_player.dart';
import 'package:just_audio/just_audio.dart';

class PlayList extends StatelessWidget {
  final List<SimpleSong> songs;

  const PlayList({super.key, required this.songs});

  String _formatDuration(Duration? duration) {
    if (duration == null) return "loading".tr; // ✅ Loading…
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final secondsStr = seconds.toString().padLeft(2, '0');
    return "$minutes:$secondsStr";
  }

  Future<Duration?> _getSongDuration(String path) async {
    try {
      final player = AudioPlayer();
      Duration? duration;
      if (path.startsWith('http')) {
        await player.setUrl(path);
        duration =
            player.duration ??
            await player.durationStream.firstWhere((d) => d != null);
      } else {
        await player.setAsset(path);
        duration = player.duration;
      }
      await player.dispose();
      return duration;
    } catch (_) {
      return null;
    }
  }

  Widget _songImage(String path, {double height = 45, double width = 45}) {
    final isNetwork = path.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetwork
          ? Image.network(
              path,
              height: height,
              width: width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: height,
                width: width,
                color: Colors.grey.shade300,
                child: const Icon(Icons.music_note, color: Colors.white),
              ),
            )
          : Image.asset(path, height: height, width: width, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final secondaryColor = theme.colorScheme.onBackground.withOpacity(0.6);

    if (songs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            "no_songs".tr, // ✅ Không có bài hát nào
            style: TextStyle(color: secondaryColor),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Text(
              "songs".tr, // ✅ Playlist
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: songs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final song = songs[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SongPlayerPage(playlist: songs, initialIndex: index),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _songImage(song.imageUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      FutureBuilder<Duration?>(
                        future: _getSongDuration(song.audioUrl),
                        builder: (context, snapshot) {
                          final duration = snapshot.data;
                          return Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.favorite_border,
                        color: secondaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
