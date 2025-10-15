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
import 'package:note1/services/song_service.dart'; // ✅ service gọi API

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final SongService _songService = SongService(); // ✅ gọi API từ Laravel
  List<dynamic> songsFromApi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadSongsFromApi();
  }

  Future<void> loadSongsFromApi() async {
    try {
      final data = await _songService.fetchSongs();
      setState(() {
        songsFromApi = data;
        isLoading = false;
      });
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
      appBar: PreferredSize(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// 🔍 Nút search
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
                              builder: (context) => const SearchMusicPage(),
                            ),
                          );
                        },
                      ),
                    ),

                    /// 🌀 Logo giữa
                    Positioned(
                      left: 135,
                      child: Image.asset(AppImages.logo, height: 32, width: 32),
                    ),

                    /// 📤 Upload + ⋮ more
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
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
                                      builder: (context) =>
                                          const UploadMusicPage(),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  height: 8,
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),

                          /// ⋮ Menu
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
                                    builder: (context) => const SettingsPage(),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _homeTopCard(),
            _tabs(),
            SizedBox(
              height: 230,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  NewsSongs(),
                  SizedBox(),
                  SizedBox(),
                  SizedBox(),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Hiển thị danh sách bài hát thật
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : PlayList(
                    songs: songsFromApi.isNotEmpty
                        ? songsFromApi.map((song) {
                            return SimpleSong(
                              title: song['title'] ?? 'Không có tiêu đề',
                              artist: song['artist'] ?? '',
                              duration: 200,
                              imageUrl: AppImages.b1,
                            );
                          }).toList()
                        : [],
                  ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

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
}
