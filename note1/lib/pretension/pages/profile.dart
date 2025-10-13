import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/settings/bloc/settings_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Avatar + Tên người dùng
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "", // TODO: tên người dùng sau này load từ API
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "0 playlists • 0 followers".tr,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 🔸 Phần playlist
              _buildSectionTitle("your_playlists".tr, textColor),
              _buildPlaylistItem("Chill vibes".tr, "50 songs".tr),
              _buildPlaylistItem("Workout Mix".tr, "30 songs".tr),
              _buildPlaylistItem("Lo-fi Beats".tr, "42 songs".tr),

              const SizedBox(height: 36),

              // 🔸 Phần cài đặt
              _buildSectionTitle("settings".tr, textColor),
              _buildSettingItem(
                icon: Icons.settings,
                title: "app_settings".tr,
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: "change_password".tr,
                onTap: () {},
              ),

              const SizedBox(height: 36),

              // 🔸 Nút đăng xuất
              ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  "logout".tr,
                  style: const TextStyle(color: Colors.red),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧩 Item playlist
  Widget _buildPlaylistItem(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: Colors.grey),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: () {},
    );
  }

  // ⚙️ Item cài đặt
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary.value),
      title: Text(title),
      onTap: onTap,
    );
  }

  // 🔠 Tiêu đề phần
  Widget _buildSectionTitle(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // 🔒 Hộp thoại đăng xuất
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("confirm_logout".tr),
        content: Text("logout_question".tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: logic đăng xuất sau này
            },
            child: Text("logout".tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
