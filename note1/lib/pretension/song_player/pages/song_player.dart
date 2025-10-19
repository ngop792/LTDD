import 'package:flutter/material.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/song_player/widgets/music_controls.dart';
import 'package:note1/pretension/song_player/pages/music_player.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';
import 'package:note1/pretension/song_player/pages/lyrics_page.dart';

class SongPlayerPage extends StatefulWidget {
  final SimpleSong song;
  const SongPlayerPage({super.key, required this.song});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  bool isFavorite = false;
  final player = MusicPlayer.instance;

  @override
  void initState() {
    super.initState();

    // ✅ Chỉ phát khi widget đã dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.playSong(widget.song.audioUrl);
    });
  }

  @override
  void dispose() {
    player.pause(); // ✅ tạm dừng khi thoát trang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        showBack: true,
        title: const Text(
          'Now playing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        action: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          ),
        ),
      ),
      body: Column(
        children: [
          _cover(),
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
                        widget.song.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.song.artist,
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

          // ✅ TRUYỀN SONG VÀO MusicControls
          MusicControls(song: widget.song),

          const SizedBox(height: 20),

          // 👉 Nút mở Lyrics
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LyricPage(
                  songTitle: widget.song.title,
                  artist: widget.song.artist,
                  imageUrl: widget.song.imageUrl,
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

  /// Ảnh bìa bài hát
  Widget _cover() => Container(
    margin: const EdgeInsets.all(20),
    height: 250,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      image: DecorationImage(
        fit: BoxFit.cover,
        image: widget.song.imageUrl.startsWith('http')
            ? NetworkImage(widget.song.imageUrl)
            : AssetImage(widget.song.imageUrl) as ImageProvider,
      ),
    ),
  );
}
