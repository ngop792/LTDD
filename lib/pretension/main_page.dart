import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note1/pretension/home/pages/home.dart';
import 'package:note1/pretension/pages/library.dart';
import 'package:note1/pretension/page/profile.dart';
import 'package:note1/core/configs/theme/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [HomePage(), LibraryPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary.value,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.library_music_outlined),
            activeIcon: const Icon(Icons.library_music),
            label: 'Library'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: 'Profile'.tr,
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
