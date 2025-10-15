import 'package:flutter/material.dart';
import 'package:note1/domain/entities/playlist.dart';

class PlaylistDetailPage extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                playlist.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/music_bg.png', fit: BoxFit.cover),
                  Container(color: Colors.black26),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "${playlist.songs.length} bài hát",
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Thêm bài hát",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
