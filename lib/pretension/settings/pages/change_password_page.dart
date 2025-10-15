import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import 'package:note1/pretension/auth/pages/signin.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPassword.text.trim(),
      );

      // ✅ Xác thực lại người dùng với mật khẩu cũ
      await user.reauthenticateWithCredential(cred);

      // ✅ Cập nhật mật khẩu mới
      await user.updatePassword(_newPassword.text.trim());

      // ✅ Đăng xuất & xóa dữ liệu cục bộ
      await FirebaseAuth.instance.signOut();
      final box = GetStorage();
      box.erase();

      // ✅ Hiển thị thông báo và chuyển đến trang đăng nhập
      getx.Get.snackbar(
        'success'.tr,
        'password_changed_success'.tr,
        snackPosition: getx.SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(seconds: 2));
      getx.Get.offAll(
        () => const SigninPage(),
        transition: getx.Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'old_password_incorrect'.tr;
          break;
        case 'weak-password':
          message = 'weak_password'.tr;
          break;
        default:
          message = 'change_password_failed'.tr;
      }

      getx.Get.snackbar(
        'error'.tr,
        message,
        snackPosition: getx.SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('change_password'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                controller: _oldPassword,
                label: 'old_password'.tr,
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPassword,
                label: 'new_password'.tr,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter_new_password'.tr;
                  }
                  if (value.length < 6) {
                    return 'password_length_error'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPassword,
                label: 'confirm_new_password'.tr,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value != _newPassword.text) {
                    return 'password_mismatch'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'confirm_change_password'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'enter_field'.trParams({'field': label});
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
