import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';
import 'package:note1/pretension/page/edit_profile.dart';
import 'package:note1/pretension/auth/pages/signup_or_signin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:note1/pretension/settings/bloc/settings_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "rs6gkiutjh1mhufzhmw68x8ws";
  String bio = "0 người theo dõi • Đang theo dõi 3";
  String? avatarPath;

  // 🔸 Hộp thoại xác nhận đăng xuất (đa ngôn ngữ)
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Xác nhận đăng xuất".tr,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          "Bạn có chắc chắn muốn đăng xuất không?".tr,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Hủy".tr,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                SnackBar(content: Text("Đang đăng xuất...".tr)),
              );

              try {
                await Supabase.instance.client.auth.signOut();

                if (context.mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text("Đăng xuất thành công".tr)),
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const SignupOrSigninPage(),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text("Lỗi đăng xuất: $e")),
                );
              }
            },
            child: Text(
              "Đăng xuất".tr,
              style: const TextStyle(color: Colors.redAccent),
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
        // THAY ĐỔI: Đặt showBack thành false để xóa nút trở về
        showBack: false,
        action: PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<int>(
              value: 0,
              child: Text(
                "Thêm vào playlist".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Text(
                "Chia sẻ".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text(
                "Cài đặt".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 0:
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Thêm vào playlist".tr)));
                break;
              case 1:
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Đã chia sẻ".tr)));
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
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
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
                        child: Text("Chỉnh sửa".tr),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        tooltip: "Đăng xuất".tr,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        "Không có hoạt động gần đây".tr,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
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
