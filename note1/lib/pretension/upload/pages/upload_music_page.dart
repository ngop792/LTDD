import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note1/core/configs/theme/app_colors.dart';

class UploadMusicPage extends StatefulWidget {
  const UploadMusicPage({super.key});

  @override
  State<UploadMusicPage> createState() => _UploadMusicPageState();
}

class _UploadMusicPageState extends State<UploadMusicPage> {
  String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Upload_Music".tr),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_rounded,
                size: 90,
                color: AppColors.primary.value,
              ),
              const SizedBox(height: 20),
              Text(
                "Upload_your_music_file_here".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // sau này thêm chọn file ở đây
                  setState(() {
                    selectedFileName = "song.mp3";
                  });
                },
                icon: const Icon(Icons.attach_file),
                label: Text(selectedFileName ?? "Choose_File".tr),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: selectedFileName == null ? null : () {},
                icon: const Icon(Icons.upload_rounded),
                label: Text("Upload".tr),
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
