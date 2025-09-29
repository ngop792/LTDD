import 'package:flutter/material.dart';
import 'package:note1/pretension/home/widgets/news_songs.dart';

import '../../../common/widgets/appbar/app_bar.dart';
import '../../../core/configs/assets/app_images.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: Image.asset(AppImages.logo, height: 40, width: 40),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _homeTopCard(),
            _tabs(),
            SizedBox(
              height: 260,
              child: TabBarView(
                controller: _tabController,
                children: [NewsSongs(), Container(), Container(), Container()],
              ),
            ),
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
              alignment: AlignmentGeometry.bottomCenter,
              child: Image.asset(AppImages.banner),
            ),
            Align(
              alignment: AlignmentGeometry.bottomRight,
              child: Padding(
                padding: const EdgeInsetsGeometry.only(right: 40),
                child: Image.asset(AppImages.homeTopCard),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return TabBar(
      controller: _tabController,
      dividerColor: Colors.transparent,
      indicatorColor: Colors.blue,
      isScrollable: false,
      // labelColor: context.isDarkMode ? Color.white : Colors.black,
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 4),
      tabs: [
        Text(
          'News',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        Text(
          'Thể loại',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        Text(
          'Artist',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        Text(
          'Podcasts',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }
}
