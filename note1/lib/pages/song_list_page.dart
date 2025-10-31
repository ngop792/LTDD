import 'package:flutter/material.dart';
import '../services/song_service.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final SongService _songService = SongService();
  late Future<List<dynamic>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = _songService.fetchSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách nhạc')),
      body: FutureBuilder<List<dynamic>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có bài nhạc nào'));
          }

          final songs = snapshot.data!;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(song['title'] ?? 'Không có tiêu đề'),
                subtitle: Text(song['artist'] ?? 'Không có nghệ sĩ'),
                onTap: () {
                  // Chỗ này sau có thể mở trang phát nhạc
                },
              );
            },
          );
        },
      ),
    );
  }
}
