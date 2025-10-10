import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorMapper {
  /// Hàm này nhận vào [FirebaseAuthException]
  /// và trả về chuỗi thông báo tiếng Việt dễ hiểu.
  static String getMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Email không hợp lệ, vui lòng nhập lại.";
      case 'user-not-found':
        return "Tài khoản không tồn tại.";
      case 'wrong-password':
        return "Sai mật khẩu, vui lòng thử lại.";
      case 'email-already-in-use':
        return "Email này đã được đăng ký.";
      case 'weak-password':
        return "Mật khẩu quá yếu, vui lòng nhập mật khẩu mạnh hơn.";
      case 'network-request-failed':
        return "Không có kết nối mạng. Vui lòng kiểm tra lại internet.";
      case 'too-many-requests':
        return "Bạn đã thử đăng nhập quá nhiều lần. Vui lòng thử lại sau.";
      case 'operation-not-allowed':
        return "Tính năng này chưa được bật cho tài khoản.";
      default:
        return "Đã xảy ra lỗi không xác định. Vui lòng thử lại.";
    }
  }
}
