import 'package:flutter/material.dart';
import 'package:note1/common/widgets/appbar/app_bar.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/auth/pages/signin.dart';
import 'package:note1/pretension/auth/pages/signup.dart';
// import 'package:note1/features/auth/login_page.dart';
// import 'package:note1/features/auth/register_page.dart';

class SignupOrSigninPage extends StatefulWidget {
  const SignupOrSigninPage({super.key});

  @override
  State<SignupOrSigninPage> createState() => _SignupOrSigninPageState();
}

class _SignupOrSigninPageState extends State<SignupOrSigninPage> {
  bool isRegisterSelected = true; // mặc định: Đăng ký

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BasicAppbar(),

            // Logo + text + button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset(AppImages.logo, width: 120, height: 120),

                  const SizedBox(height: 20),
                  const Text(
                    "Âm Nhạc Kết Nối Cảm Xúc",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Spotify is a proprietary Swedish audio streaming and media services provider",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Nút Register + Sign in với animation + navigation
                  Row(
                    children: [
                      // Nút Đăng ký
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isRegisterSelected = true;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: isRegisterSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isRegisterSelected
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                style: TextStyle(
                                  fontSize: isRegisterSelected ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: isRegisterSelected
                                      ? Colors.white
                                      : const Color.fromARGB(
                                          255,
                                          146,
                                          145,
                                          145,
                                        ),
                                ),
                                child: Transform.scale(
                                  scale: isRegisterSelected ? 1.1 : 1.0,
                                  child: const Text("Đăng ký"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Nút Đăng nhập
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isRegisterSelected = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SigninPage(),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: isRegisterSelected
                                  ? Colors.transparent
                                  : Colors.blue,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isRegisterSelected
                                    ? Colors.grey.shade400
                                    : Colors.blue,
                              ),
                            ),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                style: TextStyle(
                                  fontSize: isRegisterSelected ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: isRegisterSelected
                                      ? const Color.fromARGB(255, 141, 140, 140)
                                      : Colors.white,
                                ),
                                child: Transform.scale(
                                  scale: isRegisterSelected ? 1.0 : 1.1,
                                  child: const Text("Đăng nhập"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hình ở dưới cùng
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Image.asset(
                AppImages.listen,
                width: 280,
                height: 310,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
