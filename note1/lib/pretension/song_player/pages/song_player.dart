import 'package:flutter/material.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';
import 'package:note1/pretension/song_player/pages/lyrics_page.dart';
import 'package:note1/pretension/song_player/widgets/music_controls.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/core/controllers/player_controller.dart';

class SongPlayerPage extends StatefulWidget {
  final SimpleSong song;
  const SongPlayerPage({super.key, required this.song});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  bool isFavorite = false; // trạng thái trái tim

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        showBack: true,
        title: const Text(
          'Now playing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút lyrics trên AppBar
            IconButton(
              icon: const Icon(Icons.lyrics),
              onPressed: () {
                Navigator.push(
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
                      currentIndex: 1,
                    ),
                  ),
                );
              },
            ),
            // Nút menu ⋮
            PopupMenuButton<int>(
              icon: ValueListenableBuilder<Color>(
                valueListenable: AppColors.primary,
                builder: (context, color, _) {
                  return Icon(Icons.more_vert_rounded, color: color);
                },
              ),
              onSelected: (value) {
                if (value == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<int>(value: 0, child: Text("Thêm vào playlist")),
                PopupMenuItem<int>(value: 1, child: Text("Chia sẻ")),
                PopupMenuItem<int>(value: 2, child: Text("Cài đặt")),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _songCover(context),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.song.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.song.artist,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                ValueListenableBuilder<Color>(
                  valueListenable: AppColors.primary,
                  builder: (context, color, _) {
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 28,
                        color: isFavorite ? color : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Music controls
          const MusicControls(),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LyricPage(
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
              );
            },
            child: ValueListenableBuilder<Color>(
              valueListenable: AppColors.primary,
              builder: (context, color, _) {
                return Column(
                  children: [
                    Icon(Icons.keyboard_arrow_up, size: 24, color: color),
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

  Widget _songCover(BuildContext context) {
    final bool isNetworkImage = widget.song.imageUrl.startsWith("http");

    return Container(
      height: MediaQuery.of(context).size.height / 2.5,
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: isNetworkImage
            ? Image.network(
                widget.song.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error, size: 40));
                },
              )
            : Image.asset(
                widget.song.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
      ),
    );
  }
}
