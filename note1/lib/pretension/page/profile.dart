// profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/pretension/settings/pages/settings_page.dart';
import 'package:note1/pretension/page/edit_profile.dart';
import 'package:note1/pretension/auth/pages/signup_or_signin.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String name = "";
  String bio = "";
  String email = "";
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // 🔹 Lấy thông tin người dùng từ Firestore
  Future<void> _loadUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        name = doc.data()?['name'] ?? 'user'.tr;
        bio = doc.data()?['bio'] ?? 'no_bio'.tr;
        avatarUrl = doc.data()?['avatarUrl'];
        email = user.email ?? '';
      });
    } else {
      // Nếu user mới chưa có dữ liệu -> tạo mặc định
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName ?? 'user'.tr,
        'bio': 'no_bio'.tr,
        'avatarUrl': null,
      });
      _loadUserInfo();
    }
  }

  // 🔸 Hộp thoại xác nhận đăng xuất
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "logout_confirm".tr,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          "logout_question".tr,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "cancel".tr,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignupOrSigninPage()),
                  (route) => false,
                );
              }
            },
            child: Text(
              "logout".tr,
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
          currentAvatar: avatarUrl,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        name = result['name'] ?? name;
        bio = result['bio'] ?? bio;
        avatarUrl = result['avatar'] ?? avatarUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: BasicAppbar(
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
                "add_to_playlist".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Text(
                "share".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text(
                "settings".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
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
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : null,
                        child: avatarUrl == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : "?",
                                style: const TextStyle(
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
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
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
                        child: Text("edit_profile".tr),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        tooltip: "logout".tr,
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
                        "no_recent_activity".tr,
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
