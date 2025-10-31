import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note1/domain/entities/playlist.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/services/song_service.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/pretension/settings/bloc/settings_cubit.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';
import 'dart:math';

class Song {
  final String id;
  final String title;
  final String artist;
  final String imageUrl;
  final String audioUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.audioUrl,
  });
}

class AddSongPage extends StatefulWidget {
  final Playlist playlist;
  final Function(SimpleSong) onSongAdded;

  const AddSongPage({
    super.key,
    required this.playlist,
    required this.onSongAdded,
  });

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage>
    with TickerProviderStateMixin {
  final SongService _songService = SongService();
  final List<String> songImages = [
    AppImages.s1,
    AppImages.s2,
    AppImages.s3,
    AppImages.s4,
    AppImages.s5,
    AppImages.s6,
  ];

  List<Song> _sourceSongs = [];
  List<Song> _uploadedSongs = [];
  List<Song> currentSongs = [];

  bool isLoading = false;
  late TabController _tabController;
  int _currentTabIndex = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadOnlineSongs();
    _loadUploadedSongs();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentTabIndex = _tabController.index;
      if (_currentTabIndex == 0) {
        currentSongs = _sourceSongs;
      } else if (_currentTabIndex == 3) {
        currentSongs = _uploadedSongs;
      } else {
        currentSongs = [];
      }
    });
  }

  // 🟢 Load danh sách bài hát online (demo)
  Future<void> _loadOnlineSongs() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final songs = [
      Song(
        id: '1',
        title: "Bài Hát Mẫu",
        artist: "Ca Sĩ A",
        imageUrl: songImages[_random.nextInt(songImages.length)],
        audioUrl: "https://example.com/audio1.mp3",
      ),
      Song(
        id: '2',
        title: "Demo",
        artist: "Ai Đó",
        imageUrl: songImages[_random.nextInt(songImages.length)],
        audioUrl: "https://example.com/audio2.mp3",
      ),
      Song(
        id: '3',
        title: "Giai điệu yêu thương",
        artist: "Ngọc Linh",
        imageUrl: songImages[_random.nextInt(songImages.length)],
        audioUrl: "https://example.com/audio3.mp3",
      ),
    ];

    setState(() {
      _sourceSongs = songs;
      if (_currentTabIndex == 0) currentSongs = songs;
      isLoading = false;
    });
  }

  // 🟢 Load bài hát upload từ API
  Future<void> _loadUploadedSongs() async {
    setState(() => isLoading = true);
    try {
      final data = await _songService.fetchSongs();
      final songs = data.map<Song>((song) {
        return Song(
          id: song['id'].toString(),
          title: song['title'] ?? 'Không có tiêu đề',
          artist: song['artist'] ?? 'Không rõ',
          imageUrl:
              songImages[_random.nextInt(songImages.length)], // 🔹 random ảnh
          audioUrl: song['audio_url'] ?? song['url'] ?? '',
        );
      }).toList();

      setState(() {
        _uploadedSongs = songs;
        if (_currentTabIndex == 3) currentSongs = songs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('❌ Lỗi tải Upload songs: $e');
    }
  }

  // 🟣 Tìm kiếm bài hát
  void _filterSongs(String query) {
    final lower = query.toLowerCase();
    List<Song> filtered = [];

    if (_currentTabIndex == 0) {
      filtered = _sourceSongs
          .where(
            (song) =>
                song.title.toLowerCase().contains(lower) ||
                song.artist.toLowerCase().contains(lower),
          )
          .toList();
    } else if (_currentTabIndex == 3) {
      filtered = _uploadedSongs
          .where(
            (song) =>
                song.title.toLowerCase().contains(lower) ||
                song.artist.toLowerCase().contains(lower),
          )
          .toList();
    }

    setState(() => currentSongs = filtered);
  }

  Widget _buildSearchBar(Color accentColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white12 : accentColor.withOpacity(0.3),
          ),
        ),
        child: TextField(
          onChanged: _filterSongs,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Tìm kiếm bài hát, nghệ sĩ",
            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.white54 : accentColor,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(Color accentColor, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: _tabController,
        indicatorColor: isDark ? Colors.white54 : accentColor,
        labelColor: isDark ? Colors.white : accentColor,
        unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: const [
          Tab(text: "Online"),
          Tab(text: "Cá nhân"),
          Tab(text: "Gần đây"),
          Tab(text: "Upload"),
        ],
      ),
    );
  }

  Widget _buildSongList(List<Song> songs, Color accentColor, bool isDark) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (songs.isEmpty) {
      return const Center(
        child: Text(
          "Không có bài hát nào.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              song.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: isDark ? Colors.white54 : accentColor,
            ),
            onPressed: () async {
              if (song.audioUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Bài hát "${song.title}" chưa có URL nhạc'),
                  ),
                );
                return;
              }

              final newSong = SimpleSong(
                title: song.title,
                artist: song.artist,
                duration: 0,
                imageUrl: song.imageUrl,
                audioUrl: song.audioUrl,
              );

              if (widget.playlist.id.trim().isEmpty) {
                widget.onSongAdded(newSong);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã thêm "${song.title}" tạm thời. Lưu playlist để lưu vĩnh viễn!',
                    ),
                  ),
                );
                return;
              }

              try {
                final success = await _songService.addSongToPlaylist(
                  playlistId: widget.playlist.id,
                  songData: {'song_id': song.id, 'audio_url': song.audioUrl},
                );

                if (!success) throw Exception("API lỗi khi thêm bài hát");

                widget.onSongAdded(newSong);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã thêm "${song.title}" vào playlist "${widget.playlist.name}"',
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Thêm bài hát thất bại: $e')),
                );
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsCubit>().state;
    final accentColor = isDark
        ? Colors.white
        : SettingsPage.accentColors[settings.accentIndex];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              backgroundColor: isDark ? Colors.black : Colors.white,
              elevation: 0.5,
              centerTitle: true,
              title: Text(
                "Thêm bài hát",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Column(
                  children: [
                    _buildSearchBar(accentColor, isDark),
                    _buildTabBar(accentColor, isDark),
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.white12
                          : accentColor.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildSongList(currentSongs, accentColor, isDark), // Online
              const Center(child: Text("Danh sách bài hát Cá nhân")),
              const Center(child: Text("Danh sách bài hát Gần đây")),
              _buildSongList(currentSongs, accentColor, isDark), // Upload
            ],
          ),
        ),
      ),
    );
  }
}
