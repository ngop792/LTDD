import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChooseLanguagePage extends StatefulWidget {
  const ChooseLanguagePage({super.key});

  @override
  State<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends State<ChooseLanguagePage> {
  final box = GetStorage();
  late String _selectedLang;

  @override
  void initState() {
    super.initState();
    // Lấy ngôn ngữ đã lưu, nếu chưa có thì lấy ngôn ngữ hệ thống hoặc 'vi'
    _selectedLang = box.read('language') ?? Get.locale?.languageCode ?? 'vi';
  }

  void _changeLanguage(String langCode) {
    if (_selectedLang == langCode) return; // tránh load lại cùng 1 ngôn ngữ

    setState(() {
      _selectedLang = langCode;
    });

    // Cập nhật locale toàn app
    final locale = Locale(langCode);
    Get.updateLocale(locale);

    // Lưu vào GetStorage
    box.write('language', langCode);

    // Thông báo
    Get.snackbar(
      'Language'.tr,
      langCode == 'en'
          ? 'Switched to English'.tr
          : 'Đã chuyển sang Tiếng Việt'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('choose_language'.tr), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildLanguageCard(flag: '🇻🇳', name: 'Tiếng Việt', code: 'vi'),
            const SizedBox(height: 12),
            _buildLanguageCard(flag: '🇺🇸', name: 'English', code: 'en'),
          ],
        ),
      ),
    );
  }

  // 🔹 Giao diện chọn ngôn ngữ
  Widget _buildLanguageCard({
    required String flag,
    required String name,
    required String code,
  }) {
    final isSelected = _selectedLang == code;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _changeLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
