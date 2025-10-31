import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note1/pretension/home/widgets/news_songs.dart';
import 'package:note1/pretension/home/widgets/play_list.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';
import 'package:note1/pretension/upload/pages/upload_music_page.dart';
import 'package:note1/pretension/search/pages/search_music_page.dart';
import 'package:note1/services/song_service.dart';
import 'package:note1/services/api_constants.dart';
import 'package:note1/pretension/pages/songs_by_genre_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SongService _songService = SongService();

  List<dynamic> songsFromApi = [];
  bool isLoading = true;

  final List<String> songImages = [
    AppImages.s1,
    AppImages.s2,
    AppImages.s3,
    AppImages.s4,
    AppImages.s5,
    AppImages.s6,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // cập nhật giao diện khi đổi tab
      }
    });
    loadSongsFromApi();
  }

  Future<void> loadSongsFromApi() async {
    try {
      final data = await _songService.fetchSongs();
      setState(() {
        songsFromApi = data;
        isLoading = false;
      });
      print('🎵 Dữ liệu bài hát từ API: $songsFromApi');
    } catch (e) {
      print('❌ Lỗi khi tải bài hát: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _appBar(context, isDark),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _homeTopCard(),
          _tabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ✅ Tab 1: Tin mới
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const NewsSongs(),
                      const SizedBox(height: 10),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PlayList(
                              songs: songsFromApi.isNotEmpty
                                  ? List.generate(songsFromApi.length, (index) {
                                      final song = songsFromApi[index];
                                      final fullAudioUrl = Uri.encodeFull(
                                        (song['url'] as String?)?.replaceFirst(
                                              '10.0.2.2',
                                              ApiConstants.baseUrl.replaceFirst(
                                                '/api',
                                                '',
                                              ),
                                            ) ??
                                            '',
                                      );
                                      final title =
                                          song['title'] ?? 'Không có tiêu đề';
                                      return SimpleSong(
                                        title: title,
                                        artist:
                                            song['artist'] ??
                                            song['genre'] ??
                                            'Không rõ',
                                        duration: 200,
                                        imageUrl:
                                            songImages[index %
                                                songImages.length],
                                        audioUrl: fullAudioUrl,
                                      );
                                    })
                                  : [],
                            ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),

                // ✅ Tab 2: Thể loại
                _categoryTab(),

                // ✅ Tab 3: Nghệ sĩ
                const Center(child: Text("Artists Coming Soon...")),

                // ✅ Tab 4: Radio
                const Center(child: Text("Radio Feature Coming Soon...")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== APP BAR ==================
  PreferredSizeWidget _appBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchMusicPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 150,
                    child: Image.asset(AppImages.logo, height: 32, width: 32),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.upload_rounded,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UploadMusicPage(),
                              ),
                            );
                          },
                        ),
                        PopupMenuButton<int>(
                          icon: Icon(
                            Icons.more_vert,
                            color: theme.colorScheme.onSurface,
                          ),
                          color: theme.colorScheme.surface,
                          onSelected: (value) {
                            if (value == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsPage(),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 0,
                              child: Text("Add_to_playlist".tr),
                            ),
                            PopupMenuItem<int>(
                              value: 1,
                              child: Text("Share".tr),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Text("Setting".tr),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== TOP BANNER ==================
  Widget _homeTopCard() {
    return Center(
      child: SizedBox(
        height: 140,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(AppImages.banner),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Image.asset(AppImages.homeTopCard),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== TAB BAR ==================
  Widget _tabs() {
    final theme = Theme.of(context);
    return ValueListenableBuilder<Color>(
      valueListenable: AppColors.primary,
      builder: (context, color, _) {
        return TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorColor: color,
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          isScrollable: false,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 4),
          tabs: [
            Text(
              'News'.tr,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              'Category'.tr,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              'Artist'.tr,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              'Radio'.tr,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        );
      },
    );
  }

  // ================== TAB THỂ LOẠI ==================
  final List<Map<String, String>> genres = [
    {'name': 'Pop', 'image': AppImages.pop},
    {'name': 'Rock', 'image': AppImages.rock},
    {'name': 'Jazz', 'image': AppImages.jazz},
    {'name': 'Hip Hop', 'image': AppImages.hiphop},
    {'name': 'Classical', 'image': AppImages.classical},
  ];

  Widget _categoryTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: genres.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final genre = genres[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SongsByGenrePage(genre: genre['name']!),
              ),
            );
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(genre['image']!),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                genre['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
