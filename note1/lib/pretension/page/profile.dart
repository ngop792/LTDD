import 'dart:io';
import 'package:flutter/material.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/pretension/page/edit_profile.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "rs6gkiutjh1mhufzhmw68x8ws";
  String bio = "0 người theo dõi • Đang theo dõi 3";
  String? avatarPath;

  // 🔸 Hộp thoại xác nhận đăng xuất
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Xác nhận đăng xuất",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Bạn có chắc chắn muốn đăng xuất không?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Đã đăng xuất")));
              // TODO: thêm logic đăng xuất thật ở đây
            },
            child: const Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Mở trang chỉnh sửa hồ sơ
  Future<void> _editProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          currentName: name,
          currentBio: bio,
          currentAvatar: avatarPath,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        name = result['name'];
        bio = result['bio'];
        avatarPath = result['avatar'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: BasicAppbar(
        showBack: true,
        // 🔸 Dấu ⋮ góc phải
        action: PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => const [
            PopupMenuItem<int>(
              value: 0,
              child: Text(
                "Thêm vào playlist",
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Text("Chia sẻ", style: TextStyle(color: Colors.white)),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text("Cài đặt", style: TextStyle(color: Colors.white)),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 0:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thêm vào playlist")),
                );
                break;
              case 1:
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Đã chia sẻ")));
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
                break;
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // 🔹 Gradient nền phía trên
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6A00), Color(0xFF1C1C1C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔹 Nội dung chính
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),

                // Avatar + Tên + Thông tin
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orangeAccent,
                        backgroundImage: avatarPath != null
                            ? FileImage(File(avatarPath!))
                            : null,
                        child: avatarPath == null
                            ? const Text(
                                "R",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bio,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Nút chỉnh sửa + icon đăng xuất
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => _editProfile(context),
                        child: const Text("Chỉnh sửa"),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        tooltip: "Đăng xuất",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Phần hoạt động gần đây
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        "Không có hoạt động gần đây",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
