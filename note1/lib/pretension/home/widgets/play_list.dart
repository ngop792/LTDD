import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // ✅ cần cho .tr
import 'package:just_audio/just_audio.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/song_player/pages/song_player.dart';

class PlayList extends StatefulWidget {
  final List<SimpleSong> songs;
  final bool showPlaylist;

  const PlayList({super.key, required this.songs, this.showPlaylist = true});

  @override
  State<PlayList> createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  bool showAll = false;

  String _formatDuration(num durationInSeconds) {
    if (durationInSeconds < 0) return "0:00";
    final int seconds = durationInSeconds.toInt();
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final String secondsString = remainingSeconds.toString().padLeft(2, '0');
    return "$minutes:$secondsString";
  }

  /// ✅ Hàm này giúp lấy duration thật của file nhạc
  Future<Duration?> _getSongDuration(String path) async {
    try {
      final player = AudioPlayer();
      final completer = Completer<Duration?>();

      await player.setUrl(path).then((_) {
        final duration = player.duration;
        if (duration != null) {
          completer.complete(duration);
        } else {
          player.durationStream.firstWhere((d) => d != null).then((d) {
            completer.complete(d);
          });
        }
      });

      final result = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      await player.dispose();
      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final songs = widget.songs;
    final theme = Theme.of(context);

    final textColor = theme.colorScheme.onBackground;
    final secondaryColor = theme.colorScheme.onBackground.withOpacity(0.6);
    final backgroundColor = theme.colorScheme.surface;

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

    final displaySongs = showAll
        ? songs
        : songs.length > 4
        ? songs.sublist(0, 4)
        : songs;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showPlaylist && songs.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "songs".tr, // ✅ Bài hát
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (songs.length > 4)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showAll = !showAll;
                          });
                        },
                        child: Text(
                          showAll
                              ? "collapse".tr
                              : "see_more".tr, // ✅ Thu gọn / Xem thêm
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _songs(context, displaySongs, textColor, secondaryColor),
              const SizedBox(height: 24),
            ],
            _sectionTitle("suggest_for_you".tr, textColor), // ✅ Gợi ý cho bạn
            _horizontalSongList(context, songs, textColor, secondaryColor),
            const SizedBox(height: 24),
            _sectionTitle("featured_album".tr, textColor), // ✅ Album nổi bật
            _horizontalAlbums(context, songs),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _songs(
    BuildContext context,
    List<SimpleSong> songs,
    Color textColor,
    Color secondaryColor,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final song = songs[index];

        return FutureBuilder<Duration?>(
          future: _getSongDuration(song.audioUrl),
          builder: (context, snapshot) {
            final duration = snapshot.data?.inSeconds ?? song.duration;
            final formattedDuration = _formatDuration(duration);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongPlayerPage(
                      playlist: widget.songs,
                      initialIndex: index,
                    ),
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
                    Text(
                      formattedDuration,
                      style: TextStyle(color: secondaryColor, fontSize: 14),
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
        );
      },
    );
  }

  Widget _horizontalSongList(
    BuildContext context,
    List<SimpleSong> songs,
    Color textColor,
    Color secondaryColor,
  ) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, top: 12),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SongPlayerPage(playlist: songs, initialIndex: index),
                ),
              );
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _songImage(song.imageUrl, height: 100, width: 130),
                  const SizedBox(height: 8),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _horizontalAlbums(BuildContext context, List<SimpleSong> songs) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, top: 12),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SongPlayerPage(playlist: songs, initialIndex: index),
                ),
              );
            },
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: _getImageProvider(song.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.bottomLeft,
                child: Text(
                  song.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height,
                  width: width,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.music_note, color: Colors.white),
                );
              },
            )
          : Image.asset(path, height: height, width: width, fit: BoxFit.cover),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return AssetImage(path);
    }
  }
}
