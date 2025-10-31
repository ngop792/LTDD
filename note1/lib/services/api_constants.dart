import 'dart:io';

class ApiConstants {
  static const String emulatorBaseUrl = 'http://172.20.10.2:8000/api';
  static const String lanBaseUrl =
      'http://172.20.10.2:8000/api'; // 🔹 thay IP LAN thật của bạn
  static const String prodBaseUrl = 'https://yourdomain.com/api';
  static const bool isProduction = false;

  static String get baseUrl {
    if (isProduction) return prodBaseUrl;

    try {
      if (!_isEmulator()) {
        return lanBaseUrl;
      } else {
        return emulatorBaseUrl;
      }
    } catch (e) {
      return emulatorBaseUrl;
    }
  }

  static bool _isEmulator() {
    if (Platform.isAndroid) {
      return !Platform.environment.containsKey('ANDROID_BOOTLOGO');
    } else if (Platform.isIOS) {
      return !Platform.environment.containsKey('SIMULATOR_UDID');
    }
    return false;
  }
}
