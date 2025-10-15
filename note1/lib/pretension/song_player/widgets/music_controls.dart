import 'dart:async';
import 'package:flutter/material.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/song_player/pages/music_player.dart';

class MusicControls extends StatefulWidget {
  const MusicControls({super.key});

  @override
  State<MusicControls> createState() => _MusicControlsState();
}

class _MusicControlsState extends State<MusicControls>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  double progress = 0.0;
  Duration total = const Duration(minutes: 4, seconds: 20);
  Duration current = Duration.zero;

  bool isShuffle = false;
  int repeatMode = 0; // 0 = off, 1 = all, 2 = one

  Timer? _timer;

  late AnimationController _playController;
  late Animation<double> _scaleAnimation;

  // ✅ dùng singleton player
  final player = MusicPlayer.instance;

  @override
  void initState() {
    super.initState();

    _playController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _playController, curve: Curves.easeInOut),
    );

    // ✅ Đợi build xong rồi mới add listener để tránh lỗi build timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      player.addListener(_syncFromPlayer);
      _syncFromPlayer(); // khởi tạo trạng thái ban đầu
    });
  }

  // ✅ đồng bộ UI với player
  void _syncFromPlayer() {
    if (!mounted) return;
    setState(() {
      isPlaying = player.isPlaying;
      progress = player.total > 0 ? player.current / player.total : 0;
      total = Duration(seconds: player.total.toInt());
      current = Duration(seconds: player.current.toInt());
      isShuffle = player.isShuffle;
      repeatMode = player.repeatMode;
    });
  }

  void _togglePlay() {
    if (isPlaying) {
      _playController.reverse();
    } else {
      _playController.forward();
    }
    player.togglePlay();
  }

  void _toggleShuffle() {
    player.toggleShuffle();
  }

  void _toggleRepeat() {
    player.toggleRepeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _playController.dispose();
    player.removeListener(_syncFromPlayer);
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- progress bar ---
        ValueListenableBuilder<Color>(
          valueListenable: AppColors.primary,
          builder: (context, color, _) {
            return Slider(
              value: progress.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              activeColor: color,
              inactiveColor: Colors.grey.shade800,
              onChanged: (value) {
                setState(() {
                  progress = value;
                  current = Duration(
                    seconds: (total.inSeconds * value).round(),
                  );
                });
                player.seekFraction(value);
              },
            );
          },
        ),

        // --- time display ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<Color>(
                valueListenable: AppColors.primary,
                builder: (context, color, _) => Text(
                  _formatDuration(current),
                  style: TextStyle(color: color),
                ),
              ),
              ValueListenableBuilder<Color>(
                valueListenable: AppColors.primary,
                builder: (context, color, _) => Text(
                  _formatDuration(total),
                  style: TextStyle(color: color),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- main controls ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shuffle
            ValueListenableBuilder<Color>(
              valueListenable: AppColors.primary,
              builder: (context, color, _) => IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.shuffle,
                    key: ValueKey(isShuffle),
                    size: 28,
                    color: isShuffle ? color : Colors.white,
                  ),
                ),
                onPressed: _toggleShuffle,
              ),
            ),
            const SizedBox(width: 10),

            // Previous
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 36),
              onPressed: () {},
            ),
            const SizedBox(width: 10),

            // Play/Pause (hiệu ứng đồng bộ)
            ScaleTransition(
              scale: _scaleAnimation,
              child: ValueListenableBuilder<Color>(
                valueListenable: AppColors.primary,
                builder: (context, color, _) => IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      key: ValueKey(isPlaying),
                      size: 64,
                      color: color,
                    ),
                  ),
                  onPressed: _togglePlay,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Next
            IconButton(
              icon: const Icon(Icons.skip_next, size: 36),
              onPressed: () {},
            ),
            const SizedBox(width: 10),

            // Repeat
            ValueListenableBuilder<Color>(
              valueListenable: AppColors.primary,
              builder: (context, color, _) => IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                    key: ValueKey(repeatMode),
                    size: 28,
                    color: repeatMode == 0 ? Colors.white : color,
                  ),
                ),
                onPressed: _toggleRepeat,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
