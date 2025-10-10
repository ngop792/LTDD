import 'package:flutter/material.dart';
import 'package:note1/common/widgets/button/basic_app_button.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/choose_mode/pages/choose_mode.dart'; // import màn hình tiếp theo

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(AppImages.introBG),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: Column(
          children: [
            // Logo
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/pngtree-colorful-logo-for-music-icon-with-colored-lines-vector-png-image_6849768.png',
                width: 120,
                height: 120,
              ),
            ),

            const Spacer(),

            // Title
            const Text(
              'Enjoy Listening To Music',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 21),

            // Subtitle
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Sagittis enim purus sed phasellus. Cursus ornare id scelerisque aliquam.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Get Started button
            BasicAppButton(
              onPressed: () {
                // 👉 Chuyển sang trang ChooseModePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChooseModePage(),
                  ),
                );
              },
              title: 'Get Started',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
