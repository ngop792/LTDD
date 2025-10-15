import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/core/utils/firebase_error_mapper.dart';
import 'package:note1/pretension/auth/pages/signup.dart';
import 'package:note1/pretension/main_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: _signupText(context),
      appBar: const BasicAppbar(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildContent(context),
            if (_isLoading)
              ValueListenableBuilder<Color>(
                valueListenable: AppColors.primary,
                builder: (context, color, _) {
                  return Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: CircularProgressIndicator(color: color),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              AppImages.logo,
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Welcome Back 👋',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Sign in to continue using the app',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _emailField(context),
          const SizedBox(height: 20),
          _passwordField(context),
          const SizedBox(height: 20),

          // Nút Sign In
          ValueListenableBuilder<Color>(
            valueListenable: AppColors.primary,
            builder: (context, color, _) {
              return ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog(FirebaseErrorMapper.getMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign In Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email_outlined),
        hintText: 'Enter Email',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 28,
          horizontal: 40,
        ),
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        hintText: 'Password',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 28,
          horizontal: 40,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  Widget _signupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Not a member?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          ValueListenableBuilder<Color>(
            valueListenable: AppColors.primary,
            builder: (context, color, _) {
              return TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: color),
                child: const Text(
                  'Register Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
