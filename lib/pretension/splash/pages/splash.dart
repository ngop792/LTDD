import 'package:flutter/material.dart';
import 'package:note1/pretension/intro/pages/get_started.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GetStartedPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/images/pngtree-colorful-logo-for-music-icon-with-colored-lines-vector-png-image_6849768.png',
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
