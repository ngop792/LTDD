import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/song_player/widgets/music_controls.dart';
import 'package:note1/pretension/song_player/pages/music_player.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';
import 'package:note1/pretension/song_player/pages/lyrics_page.dart';
import 'package:just_audio/just_audio.dart';

class SongPlayerPage extends StatefulWidget {
  final List<SimpleSong> playlist;
  final int initialIndex;

  const SongPlayerPage({
    super.key,
    required this.playlist,
    this.initialIndex = 0,
  });

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  bool isFavorite = false;
  final player = MusicPlayer.instance;
  late int currentIndex;
  StreamSubscription<ProcessingState>? _playerSub;

  SimpleSong get currentSong => widget.playlist[currentIndex];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.playSong(currentSong.audioUrl);
      _listenForSongEnd();
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    player.pause();
    super.dispose();
  }

  void _listenForSongEnd() {
    _playerSub = player.audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _changeSong(next: true);
      }
    });
  }

  /// 🔄 Hàm duy nhất xử lý chuyển bài
  void _changeSong({bool next = true}) {
    int newIndex = currentIndex;

    // Repeat one
    if (player.repeatMode == 2) {
      player.playSong(currentSong.audioUrl);
      return;
    }

    // Shuffle
    if (player.isShuffle) {
      do {
        newIndex = Random().nextInt(widget.playlist.length);
      } while (newIndex == currentIndex && widget.playlist.length > 1);
    } else {
      if (next) {
        // Next
        if (currentIndex < widget.playlist.length - 1) {
          newIndex++;
        } else if (player.repeatMode == 1) {
          newIndex = 0;
        } else {
          return; // hết playlist
        }
      } else {
        // Previous
        if (currentIndex > 0) {
          newIndex--;
        } else if (player.repeatMode == 1) {
          newIndex = widget.playlist.length - 1;
        } else {
          return; // đầu playlist
        }
      }
    }

    setState(() => currentIndex = newIndex);
    player.playSong(currentSong.audioUrl);
  }

  void _playNext() => _changeSong(next: true);
  void _playPrevious() => _changeSong(next: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        showBack: true,
        title: const Text(
          'Now playing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        action: PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem<int>(value: 0, child: Text("Add to playlist")),
            const PopupMenuItem<int>(value: 1, child: Text("Share")),
            const PopupMenuItem<int>(value: 2, child: Text("Settings")),
          ],
          onSelected: (value) {
            if (value == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            } else if (value == 0) {
              // TODO: Add to playlist
            } else if (value == 1) {
              // TODO: Share song
            }
          },
        ),
      ),
      body: Column(
        children: [
          _cover(currentSong.imageUrl),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentSong.artist,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => setState(() => isFavorite = !isFavorite),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // MusicControls
          MusicControls(
            song: currentSong,
            onNext: _playNext,
            onPrevious: _playPrevious,
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LyricPage(
                  songTitle: currentSong.title,
                  artist: currentSong.artist,
                  imageUrl: currentSong.imageUrl,
                  lyrics: [
                    "Em ơi em ở lại, nhà anh vẫn có chờ ai...",
                    "Cơn mưa rơi nhẹ rơi, ngoài hiên đã ướt đôi vai...",
                    "Tình yêu như gió bay đi mất, chỉ còn lại nỗi nhớ...",
                    "Bao năm qua anh vẫn đợi em về...",
                  ],
                ),
              ),
            ),
            child: ValueListenableBuilder<Color>(
              valueListenable: AppColors.primary,
              builder: (context, color, _) {
                return Column(
                  children: [
                    Icon(Icons.keyboard_arrow_up, color: color),
                    Text("Lyrics", style: TextStyle(color: color)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cover(String imageUrl) => Container(
    margin: const EdgeInsets.all(20),
    height: 250,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      image: DecorationImage(
        fit: BoxFit.cover,
        image: imageUrl.startsWith('http')
            ? NetworkImage(imageUrl)
            : AssetImage(imageUrl) as ImageProvider,
      ),
    ),
  );
}
