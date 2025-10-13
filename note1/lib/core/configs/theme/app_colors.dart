import 'package:flutter/material.dart';

class AppColors {
  // Màu chủ đạo runtime, khởi tạo là blue nhưng sẽ được override từ settings
  static ValueNotifier<Color> primary = ValueNotifier<Color>(Colors.blue);

  static const lightBackground = Color(0xffF2F2F2);
  static const darkBackground = Color(0xff0D0C0C);
  static const grey = Color(0xffBEBEBE);
  static const darkGrey = Color(0xff343434);

  // Hàm cập nhật màu runtime
  static void setPrimary(Color color) {
    primary.value = color;
  }

  // ✅ Thêm getter background
  static Color background(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }
}
