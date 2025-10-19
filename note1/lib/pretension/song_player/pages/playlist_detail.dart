// File: playlist_detail.dart

import 'package:flutter/material.dart';
import 'package:note1/domain/entities/playlist.dart';
import 'package:note1/pretension/song_player/pages/add_song_page.dart';

class PlaylistDetailPage extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  // --- Widget helper: Nút Quay lại Tùy chỉnh (Hình tròn) ---
  Widget _buildCustomBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 18,
          ),
        ),
      ),
    );
  }

  // --- Widget helper: Ảnh bìa ---
  Widget _buildCoverImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.music_note, size: 100, color: Colors.grey.shade400),
      ),
    );
  }

  // --- Widget helper: Nút Thêm Bài ---
  Widget _buildAddSongButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSongPage(playlist: playlist),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          "THÊM BÀI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // --- Widget helper: Thông báo playlist trống ---
  Widget _buildEmptyPlaylistMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        "Không có bài hát trong playlist của bạn. Tìm bài hát để thêm vào playlist của bạn",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String playlistAuthor = playlist.author;
    final int songCount = playlist.songs.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: _buildCustomBackButton(context),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              _buildCoverImage(),
              const SizedBox(height: 20),
              Text(
                playlist.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$songCount bài hát • bởi $playlistAuthor",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),
              _buildAddSongButton(context),
              const SizedBox(height: 50),
              if (songCount == 0) _buildEmptyPlaylistMessage(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
