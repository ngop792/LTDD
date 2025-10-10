import 'package:flutter/material.dart';
import 'package:note1/pretension/home/widgets/news_songs.dart';
import 'package:note1/pretension/home/widgets/play_list.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<SimpleSong> sampleSongs = [
    SimpleSong(
      title: "As It Was",
      artist: "Harry Styles",
      duration: 333,
      imageUrl: AppImages.b1,
    ),
    SimpleSong(
      title: "God Did",
      artist: "DJ Khaled",
      duration: 223,
      imageUrl: AppImages.b1,
    ),
    SimpleSong(
      title: "Heat Waves",
      artist: "Glass Animals",
      duration: 238,
      imageUrl: AppImages.b1,
    ),
    SimpleSong(
      title: "STAY",
      artist: "The Kid LAROI & Justin Bieber",
      duration: 141,
      imageUrl: AppImages.b1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
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
                    /// 🔍 Nút search bên trái
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.black87),
                        onPressed: () {},
                      ),
                    ),

                    /// 🌀 Logo giữa
                    Positioned(
                      left: 135,
                      child: Image.asset(AppImages.logo, height: 32, width: 32),
                    ),

                    /// 📤 Upload + ⋮ bên phải
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.upload_rounded,
                                  color: Colors.black87,
                                ),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  height: 8,
                                  width: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),

                          /// ⋮ PopupMenuButton
                          PopupMenuButton<int>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.black87,
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
                              PopupMenuItem<int>(
                                value: 0,
                                child: Text("Thêm vào playlist"),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text("Chia sẻ"),
                              ),
                              PopupMenuItem<int>(
                                value: 2,
                                child: Text("Cài đặt"),
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
            PlayList(songs: sampleSongs),
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
    return ValueListenableBuilder<Color>(
      valueListenable: AppColors.primary,
      builder: (context, color, _) {
        return TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorColor: color,
          isScrollable: false,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 4),
          tabs: const [
            Text(
              'News',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              'Artist',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              'Radio',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        );
      },
    );
  }
}
