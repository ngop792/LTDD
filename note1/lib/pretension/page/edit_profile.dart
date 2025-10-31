import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http_parser/http_parser.dart';

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

  Uint8List? pickedImageBytes;
  bool isSaving = false;
  double uploadProgress = 0;
  String? newAvatarUrl;

  final String cloudName = "dza1p7sje";
  final String uploadPreset = "unsigned_preset";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    bioController = TextEditingController(text: widget.currentBio);
    newAvatarUrl = widget.currentAvatar;
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedXFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedXFile == null) return;

      final Uint8List originalBytes = await pickedXFile.readAsBytes();

      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithList(
            originalBytes,
            quality: 75,
            minWidth: 1080,
            minHeight: 1080,
            format: CompressFormat.jpeg,
          );

      if (compressedBytes == null) {
        Get.snackbar('error'.tr, 'cannot_compress_image'.tr);
        return;
      }

      setState(() {
        pickedImageBytes = compressedBytes;
      });
    } catch (e) {
      debugPrint("❌ Lỗi chọn ảnh: $e");
      Get.snackbar('error'.tr, 'cannot_pick_image'.tr);
    }
  }

  Future<String?> uploadToCloudinary(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: 'avatar.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['secure_url'];
      } else {
        debugPrint("❌ Upload lỗi: ${res.body}");
        Get.snackbar('error'.tr, 'cannot_upload_image'.tr);
        return null;
      }
    } catch (e) {
      debugPrint("❌ Lỗi Cloudinary: $e");
      Get.snackbar('error'.tr, 'cannot_upload_image'.tr);
      return null;
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('error'.tr, 'user_not_found'.tr);
      setState(() => isSaving = false);
      return;
    }

    try {
      String? avatarUrl = newAvatarUrl;

      if (pickedImageBytes != null) {
        avatarUrl = await uploadToCloudinary(pickedImageBytes!);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        "name": nameController.text.trim(),
        "bio": bioController.text.trim(),
        "avatarUrl": avatarUrl ?? "",
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() => newAvatarUrl = avatarUrl);

      if (mounted) {
        Navigator.pop(context, {
          'name': nameController.text.trim(),
          'bio': bioController.text.trim(),
          'avatar': avatarUrl,
        });
      }

      Get.snackbar('success'.tr, 'profile_saved'.tr);
    } catch (e) {
      debugPrint("❌ Lỗi lưu profile: $e");
      Get.snackbar('error'.tr, 'cannot_save_profile'.tr);
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    ImageProvider? avatarProvider;
    if (pickedImageBytes != null) {
      avatarProvider = MemoryImage(pickedImageBytes!);
    } else if (newAvatarUrl != null && newAvatarUrl!.isNotEmpty) {
      avatarProvider = NetworkImage(newAvatarUrl!);
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('edit_profile'.tr),
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
                backgroundImage: avatarProvider,
                child: avatarProvider == null
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
                labelText: 'display_name'.tr,
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
                labelText: 'short_bio'.tr,
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isSaving ? null : saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text('save_changes'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
