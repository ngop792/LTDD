import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final String? currentAvatar;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentBio,
    this.currentAvatar,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  File? avatarFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    bioController = TextEditingController(text: widget.currentBio);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        avatarFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('edit_profile'.tr), // 🔹 Đa ngôn ngữ
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: avatarFile != null
                    ? FileImage(avatarFile!)
                    : (widget.currentAvatar != null
                          ? FileImage(File(widget.currentAvatar!))
                          : null),
                child: avatarFile == null && widget.currentAvatar == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: isDark ? Colors.white70 : Colors.black45,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'display_name'.tr, // 🔹 Đa ngôn ngữ
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'short_bio'.tr, // 🔹 Đa ngôn ngữ
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'bio': bioController.text,
                  'avatar': avatarFile?.path,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text('save_changes'.tr), // 🔹 Đa ngôn ngữ
            ),
          ],
        ),
      ),
    );
  }
}
