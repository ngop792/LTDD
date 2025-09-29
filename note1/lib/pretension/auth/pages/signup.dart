import 'package:flutter/material.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/pretension/auth/pages/signin.dart';
import 'package:note1/data/models/auth/create_user_req.dart';
import 'package:note1/service_locator.dart';
import "package:note1/domain/usecase/auth/signup.dart";

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildContent(context),

            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
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
            'Create Account 🎵',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Fill in your details to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          _fullNameField(),
          const SizedBox(height: 20),

          _emailField(),
          const SizedBox(height: 20),

          _passwordField(),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _signUp,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "Create Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Do you have an account?',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SigninPage()),
                  );
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    var result = await sl<SignupUseCase>().call(
      params: CreateUserReq(
        fullName: _fullName.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
      ),
    );

    if (!mounted) return;

    result.fold((l) => _showErrorDialog(l.toString()), (r) {
      // 👉 Thành công → về SignIn
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninPage()),
      );
    });

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Up Failed"),
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

  Widget _fullNameField() {
    return TextField(
      controller: _fullName,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person_outline),
        hintText: 'Full Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.email_outlined),
        hintText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _password,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        hintText: 'Password',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
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
}
