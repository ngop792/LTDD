import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'vi': {
      // Change Password
      'old_password': 'Mật khẩu cũ',
      'new_password': 'Mật khẩu mới',
      'confirm_new_password': 'Xác nhận mật khẩu mới',
      'confirm_change_password': 'Xác nhận đổi mật khẩu',
      'success': 'Thành công',
      'error': 'Lỗi',
      'password_changed_success':
          'Mật khẩu đã được thay đổi. Vui lòng đăng nhập lại.',
      'old_password_incorrect': 'Mật khẩu cũ không đúng.',
      'weak_password': 'Mật khẩu mới quá yếu.',
      'change_password_failed': 'Đổi mật khẩu thất bại.',
      'enter_new_password': 'Vui lòng nhập mật khẩu mới',
      'password_length_error': 'Mật khẩu phải từ 6 ký tự trở lên',
      'password_mismatch': 'Mật khẩu xác nhận không khớp',
      'enter_field': 'Vui lòng nhập @field',

      // Chung
      'app_name': 'Note 1',
      'ok': 'Đồng ý',
      'cancel': 'Hủy',
      'yes': 'Có',
      'no': 'Không',

      // Splash / Intro
      'welcome': 'Chào mừng bạn đến với Note 1!',
      'loading': 'Đang tải...',

      // Đăng nhập / Đăng ký
      'signin': 'Đăng nhập',
      'signup': 'Đăng ký',
      'email': 'Email',
      'password': 'Mật khẩu',
      'confirm_password': 'Xác nhận mật khẩu',
      'forgot_password': 'Quên mật khẩu?',
      'dont_have_account': 'Chưa có tài khoản?',
      'already_have_account': 'Đã có tài khoản?',
      'login_success': 'Đăng nhập thành công',
      'signup_success': 'Đăng ký thành công',
      'edit_profile': 'Chỉnh sửa hồ sơ',
      'display_name': 'Tên hiển thị',
      'short_bio': 'Mô tả ngắn',
      'save_changes': 'Lưu thay đổi',

      // Trang chọn ngôn ngữ
      'choose_language': 'Chọn ngôn ngữ',
      'language': 'Ngôn ngữ',
      'switched_to_english': 'Đã chuyển sang tiếng Anh',
      'switched_to_vietnamese': 'Đã chuyển sang tiếng Việt',
      'app_settings': 'Cài đặt ứng dụng',
      'change_password': 'Đổi mật khẩu',
      'logout': 'Đăng xuất',
      'confirm_logout': 'Xác nhận đăng xuất',
      'logout_question': 'Bạn có chắc chắn muốn đăng xuất không?',

      // Settings
      'settings': 'Cài đặt',
      'interface': 'Giao diện',
      'theme_mode': 'Chế độ sáng',
      'accent_color': 'Màu chủ đạo',
      'font_size': 'Cỡ chữ',
      'small': 'Nhỏ',
      'normal': 'Bình thường',
      'large': 'Lớn',
      'light_mode': 'Chế độ sáng',
      'account_security': 'Tài khoản & bảo mật',
      'privacy_policy': 'Điều lệ & Bảo mật',
      'version': 'Phiên bản',
      'Setting': 'Cài đặt',
      'Share': 'Chia sẻ',
      'Add_to_playlist': 'Thêm vào playlist',
      'Home': 'Trang chủ',
      'Library': 'Thư viện',
      'Profile': "Trang cá nhân",
      'News': 'Tin mới',
      'Category': 'Thể loại',
      'Artist': 'Nghệ sĩ',
      'Radio': 'Radio',
      'Xác nhận đăng xuất': 'Confirm logout',
    },
    'en': {
      // Common
      'app_name': 'Note 1',
      'ok': 'OK',
      'cancel': 'Cancel',
      'yes': 'Yes',
      'no': 'No',

      'settings': 'Settings',
      'app_settings': 'App Settings',
      'change_password': 'Change Password',
      'logout': 'Logout',
      'confirm_logout': 'Confirm Logout',
      'logout_question': 'Are you sure you want to log out?',

      // Splash / Intro
      'welcome': 'Welcome to Note 1!',
      'loading': 'Loading...',

      // Auth
      'signin': 'Sign In',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'dont_have_account': 'Don\'t have an account?',
      'already_have_account': 'Already have an account?',
      'login_success': 'Login successful',
      'signup_success': 'Signup successful',

      // Language Page
      'choose_language': 'Choose language',
      'language': 'Language',
      'switched_to_english': 'Switched to English',
      'switched_to_vietnamese': 'Switched to Vietnamese',

      // Settings
      'interface': 'Interface',
      'theme_mode': 'Light Mode',
      'accent_color': 'Accent Color',
      'font_size': 'Font Size',
      'small': 'Small',
      'normal': 'Normal',
      'large': 'Large',
      'account_security': 'Account & Security',
      'privacy_policy': 'Terms & Privacy',
      'version': 'Version',
      'News': 'News',
      'Category': 'Category',
      'Artist': 'Artist',
      'Radio': 'Radio',
      'add_to_playlist': 'Add to playlist',
      'share': 'Share',
      'Setting': 'Setting',
      'Home': 'Home',
      'Library': 'Library',
      'Profile': 'Profile',
      'Xác nhận đăng xuất': 'Confirm logout',
      'Are you sure you want to log out?': 'Are you sure you want to log out?',
      'Edit': 'Edit',
      'No recent activity': 'No recent activity',

      // Change Password
      'old_password': 'Old Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'confirm_change_password': 'Confirm Change Password',
      'success': 'Success',
      'error': 'Error',
      'password_changed_success':
          'Password has been changed. Please sign in again.',
      'old_password_incorrect': 'Old password is incorrect.',
      'weak_password': 'New password is too weak.',
      'change_password_failed': 'Failed to change password.',
      'enter_new_password': 'Please enter a new password',
      'password_length_error': 'Password must be at least 6 characters long',
      'password_mismatch': 'Passwords do not match',
      'enter_field': 'Please enter @field',
    },
  };
}
