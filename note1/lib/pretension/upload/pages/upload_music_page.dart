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

  // ✅ Thêm biến hiển thị thể loại dự đoán
  String? predictedGenre;

  /// 🔹 Chọn file nhạc
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
        withData: true,
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

  /// 🔹 Upload lên Laravel + AI Dự đoán
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

    setState(() {
      isUploading = true;
      predictedGenre = null; // reset thể loại cũ
    });

    try {
      bool success = false;
      Map<String, dynamic>? predictRes;
      String? genre;

      // ✅ Upload và gọi AI
      if (kIsWeb) {
        success = await ApiService.uploadSongWeb(
          title,
          selectedBytes ?? Uint8List(0),
          fileName ?? 'audio.mp3',
        );

        if (success) {
          predictRes = await ApiService.predictGenreWeb(
            selectedBytes ?? Uint8List(0),
            fileName ?? 'audio.mp3',
          );
          genre = predictRes?['genre'];
        }
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

        if (success) {
          predictRes = await ApiService.predictGenre(selectedFile!.path ?? '');
          genre = predictRes?['genre'];
        }
      }

      // ✅ Xử lý phản hồi
      if (success) {
        Get.snackbar(
          "✅ Thành công",
          "Tải bài hát lên thành công! ${genre != null ? "Thể loại: $genre" : ""}",
          snackPosition: SnackPosition.BOTTOM,
        );

        setState(() {
          titleController.clear();
          selectedFile = null;
          selectedBytes = null;
          fileName = null;
          predictedGenre = genre;
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
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Get.back(),
        ),
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

              // Tiêu đề bài hát
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

              // Chọn file
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

              if (selectedBytes != null || selectedFile != null)
                Text(
                  "📁 ${fileName ?? selectedFile!.path.split('/').last}",
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(height: 20),

              // Upload button
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

              // ✅ Thể loại AI
              if (predictedGenre != null) ...[
                const SizedBox(height: 25),
                Text(
                  "🎧 Thể loại dự đoán: $predictedGenre",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
