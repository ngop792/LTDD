import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:note1/services/api_service.dart';
import 'package:note1/core/configs/theme/app_colors.dart';

class UploadMusicPage extends StatefulWidget {
  const UploadMusicPage({super.key});

  @override
  State<UploadMusicPage> createState() => _UploadMusicPageState();
}

class _UploadMusicPageState extends State<UploadMusicPage> {
  File? selectedFile;
  Uint8List? selectedBytes;
  String? fileName;
  bool isUploading = false;
  final TextEditingController titleController = TextEditingController();

  /// 🔹 Chọn file nhạc
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
        withData: true, // cần cho Web
      );

      if (result != null) {
        setState(() {
          fileName = result.files.single.name;
          if (kIsWeb) {
            selectedBytes = result.files.single.bytes;
          } else {
            final path = result.files.single.path;
            if (path != null) selectedFile = File(path);
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể chọn file: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 🔹 Upload lên Laravel
  Future<void> uploadMusic() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        "Thiếu tiêu đề",
        "Vui lòng nhập tên bài hát!",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Nếu chưa chọn file
    if ((kIsWeb && selectedBytes == null) ||
        (!kIsWeb && selectedFile == null)) {
      bool confirm = false;
      await Get.defaultDialog(
        title: "Không có file nhạc",
        middleText: "Bạn chỉ muốn tải tiêu đề lên?",
        textConfirm: "Có",
        textCancel: "Không",
        confirmTextColor: Colors.white,
        onConfirm: () {
          confirm = true;
          Get.back();
        },
      );
      if (!confirm) return;
    }

    setState(() => isUploading = true);

    try {
      bool success = false;

      if (kIsWeb) {
        success = await ApiService.uploadSongWeb(
          title,
          selectedBytes ?? Uint8List(0),
          fileName ?? 'audio.mp3',
        );
      } else {
        if (selectedFile == null || !await selectedFile!.exists()) {
          Get.snackbar(
            "Lỗi",
            "File không tồn tại trên thiết bị!",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        success = await ApiService.uploadSong(title, selectedFile!.path);
      }

      if (success) {
        Get.snackbar(
          "✅ Thành công",
          "Tải bài hát lên thành công!",
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() {
          titleController.clear();
          selectedFile = null;
          selectedBytes = null;
          fileName = null;
        });
      } else {
        Get.snackbar(
          "❌ Thất bại",
          "Không thể tải lên. Hãy thử lại!",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Đã xảy ra lỗi khi tải lên: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tải nhạc lên"),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(
                Icons.library_music_rounded,
                size: 100,
                color: AppColors.primary.value,
              ),
              const SizedBox(height: 30),

              // Nhập tiêu đề
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Tên bài hát",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nút chọn file
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  fileName ??
                      selectedFile?.path.split('/').last ??
                      "Chọn file nhạc",
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Nếu có file, hiển thị thêm kích thước
              if (selectedBytes != null || selectedFile != null)
                Text(
                  "📁 ${fileName ?? selectedFile!.path.split('/').last}",
                  style: const TextStyle(fontSize: 14),
                ),

              const SizedBox(height: 20),

              // Nút upload
              ElevatedButton.icon(
                onPressed: isUploading ? null : uploadMusic,
                icon: isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(isUploading ? "Đang tải..." : "Tải lên"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
