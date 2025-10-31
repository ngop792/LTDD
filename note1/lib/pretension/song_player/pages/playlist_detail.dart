// playlist_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note1/domain/entities/playlist.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/services/song_service.dart';
import 'package:note1/pretension/song_player/pages/add_song_page.dart';
import 'package:note1/pretension/song_player/pages/song_player.dart';
import 'package:note1/core/configs/assets/app_images.dart';

final List<String> defaultSongImages = [
  AppImages.s1,
  AppImages.s2,
  AppImages.s3,
  AppImages.s4,
  AppImages.s5,
  AppImages.s6,
];

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final SongService _service = SongService();
  bool _isLoadingSongs = true;
  List<SimpleSong> _songs = [];
  List<SimpleSong> _tempSongs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoadingSongs = true;
      _songs = [];
    });

    if (widget.playlist.id.isEmpty) {
      setState(() {
        _songs = _tempSongs;
        _isLoadingSongs = false;
      });
      return;
    }

    try {
      final fetchedSongsJson = await _service.fetchSongsInPlaylist(
        widget.playlist.id,
      );
      final fetchedSongs = fetchedSongsJson
          .map<SimpleSong>((json) => SimpleSong.fromJson(json))
          .toList();

      final mergedSongs = [
        ..._tempSongs.where((s) => s.audioUrl.isNotEmpty),
        ...fetchedSongs,
      ];

      setState(() {
        _songs = mergedSongs;
        _isLoadingSongs = false;
      });
    } catch (e) {
      debugPrint("❌ ${'error_loading_songs'.tr}: $e");
      setState(() => _isLoadingSongs = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'error_loading_songs'.tr}: $e')),
      );
    }
  }

  Future<void> _deletePlaylist() async {
    final success = await _service.deletePlaylist(widget.playlist.id);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'playlist_deleted'.tr} "${widget.playlist.name}"'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('playlist_delete_failed'.tr),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('delete_playlist'.tr, style: theme.textTheme.titleMedium),
        content: Text(
          'delete_playlist_question'.tr,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr, style: theme.textTheme.labelLarge),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePlaylist();
            },
            child: Text(
              'delete'.tr,
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _onSongAdded(SimpleSong song) {
    debugPrint('Added song: ${song.title}, audioUrl: ${song.audioUrl}');
    setState(() {
      _songs.insert(0, song);
      if (song.id.isEmpty) _tempSongs.insert(0, song);
    });
  }

  Future<void> _removeSong(SimpleSong song) async {
    if (song.id.isNotEmpty && widget.playlist.id.isNotEmpty) {
      final success = await _service.removeSongFromPlaylist(
        playlistId: widget.playlist.id,
        songId: song.id,
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('song_delete_failed'.tr),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    setState(() {
      _songs.removeWhere((s) => s == song);
      _tempSongs.removeWhere((s) => s == song);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'song_deleted'.tr} "${song.title}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCustomBackButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: theme.iconTheme.color,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCover() {
    final firstFourSongs = _songs.take(4).toList();

    if (firstFourSongs.isEmpty) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            AppImages.defaultPlaylistCover,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: firstFourSongs.length,
          itemBuilder: (context, index) {
            final song = firstFourSongs[index];
            final imageUrl = song.imageUrl.isNotEmpty
                ? song.imageUrl
                : defaultSongImages[index % defaultSongImages.length];

            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Image.asset(AppImages.s1, fit: BoxFit.cover),
                    )
                  : Image.asset(imageUrl, fit: BoxFit.cover),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddSongButton(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSongPage(
                playlist: widget.playlist,
                onSongAdded: _onSongAdded,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.cardColor,
          foregroundColor: theme.textTheme.labelLarge?.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: theme.dividerColor, width: 1),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          'add_song'.tr.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    final theme = Theme.of(context);

    if (_isLoadingSongs)
      return const Center(child: CircularProgressIndicator());

    if (_songs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Text(
          'no_songs_in_playlist'.tr,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _songs.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: theme.dividerColor),
      itemBuilder: (context, index) {
        final song = _songs[index];
        final imageIndex = index % defaultSongImages.length;
        final imageUrl = song.imageUrl.isNotEmpty
            ? song.imageUrl
            : defaultSongImages[imageIndex];

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      AppImages.s1,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
          title: Text(song.title, style: theme.textTheme.bodyMedium),
          subtitle: Text(song.artist, style: theme.textTheme.bodySmall),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => _removeSong(song),
          ),
          onTap: () {
            if (song.audioUrl.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('song_no_url'.tr),
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }
            final songsCopy = List<SimpleSong>.from(_songs);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SongPlayerPage(playlist: songsCopy, initialIndex: index),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playlistAuthor = widget.playlist.author;
    final songCount = _songs.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: _buildCustomBackButton(context),
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              _buildPlaylistCover(),
              const SizedBox(height: 20),
              Text(
                widget.playlist.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$songCount ${'songs'.tr} • ${'by'.tr} $playlistAuthor",
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 30),
              _buildAddSongButton(context),
              const SizedBox(height: 20),
              _buildSongList(),
            ],
          ),
        ),
      ),
    );
  }
}
