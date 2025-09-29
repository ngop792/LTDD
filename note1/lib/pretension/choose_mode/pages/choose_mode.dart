import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note1/common/widgets/button/basic_app_button.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/auth/pages/signup_or_signin.dart';
import 'package:note1/pretension/choose_mode/bloc/theme_cubi.dart';

class ChooseModePage extends StatefulWidget {
  const ChooseModePage({super.key});

  @override
  State<ChooseModePage> createState() => _ChooseModePageState();
}

class _ChooseModePageState extends State<ChooseModePage> {
  ThemeMode? _selectedMode;

  void _onSelectMode(ThemeMode mode) {
    setState(() {
      _selectedMode = mode;
    });
    context.read<ThemeCubit>().updateTheme(mode);
  }

  Widget _buildModeButton({
    required String label,
    required String iconPath,
    required ThemeMode mode,
  }) {
    final bool isSelected = _selectedMode == mode;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _onSelectMode(mode),
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0, // zoom in khi chọn
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack, // tạo hiệu ứng bounce
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xff30393C).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(iconPath, fit: BoxFit.none),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 17,
            color: isSelected
                ? Colors.white
                : const Color.fromARGB(255, 15, 14, 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(AppImages.chooseModeBG),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/pngtree-colorful-logo-for-music-icon-with-colored-lines-vector-png-image_6849768.png',
                width: 120,
                height: 120,
              ),
            ),

            const Spacer(),

            const Text(
              'Choose Mode',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildModeButton(
                  label: 'Light Mode',
                  iconPath: AppImages.sun,
                  mode: ThemeMode.light,
                ),
                const SizedBox(width: 70),
                _buildModeButton(
                  label: 'Dark Mode',
                  iconPath: AppImages.moon,
                  mode: ThemeMode.dark,
                ),
              ],
            ),

            const SizedBox(height: 100),

            BasicAppButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupOrSigninPage(),
                  ),
                );
                // TODO: Chuyển sang màn hình tiếp theo
              },
              title: 'Continue',
            ),
          ],
        ),
      ),
    );
  }
}
