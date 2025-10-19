import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/song_player/pages/music_player.dart';

class MusicControls extends StatefulWidget {
  final SimpleSong song;
  const MusicControls({super.key, required this.song});

  @override
  State<MusicControls> createState() => _MusicControlsState();
}

class _MusicControlsState extends State<MusicControls>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  double progress = 0.0;
  Duration total = Duration.zero;
  Duration current = Duration.zero;
  bool isShuffle = false;
  int repeatMode = 0;

  late final MusicPlayer player;
  late final AnimationController _playController;
  late final Animation<double> _scaleAnimation;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  bool _isDragging = false; // 🔹 Trạng thái đang kéo thanh

  @override
  void initState() {
    super.initState();
    player = MusicPlayer.instance;

    _playController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _playController, curve: Curves.easeInOut),
    );

    _sync();
    _listenStreams();
  }

  void _listenStreams() {
    final audio = player.audioPlayer;

    _posSub = audio.positionStream.listen((pos) {
      if (!mounted || _isDragging) return;
      setState(() {
        current = pos;
        progress = player.total > 0 ? pos.inSeconds / player.total : 0;
      });
    });

    _durSub = audio.durationStream.listen((dur) {
      if (!mounted) return;
      if (dur != null) {
        setState(() => total = dur);
      }
    });

    _stateSub = audio.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => isPlaying = state.playing);
    });
  }

  void _sync() {
    setState(() {
      isPlaying = player.isPlaying;
      progress = player.total > 0 ? player.current / player.total : 0;
      total = Duration(seconds: player.total.toInt());
      current = Duration(seconds: player.current.toInt());
      isShuffle = player.isShuffle;
      repeatMode = player.repeatMode;
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _playController.dispose();
    super.dispose();
  }

  String _format(Duration d) =>
      "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";

  void _toggleShuffle() {
    player.toggleShuffle();
    setState(() => isShuffle = player.isShuffle);
  }

  void _toggleRepeat() {
    player.toggleRepeat();
    setState(() => repeatMode = player.repeatMode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Thanh tiến trình =====
        ValueListenableBuilder<Color>(
          valueListenable: AppColors.primary,
          builder: (context, color, _) {
            return Slider(
              value: progress.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              activeColor: color,
              inactiveColor: Colors.grey.shade800,

              // 🔹 Khi bắt đầu kéo
              onChangeStart: (v) {
                setState(() => _isDragging = true);
              },

              // 🔹 Khi đang kéo
              onChanged: (v) {
                setState(() {
                  progress = v;
                  current = Duration(seconds: (player.total * v).toInt());
                });
              },

              // 🔹 Khi thả tay
              onChangeEnd: (v) {
                setState(() => _isDragging = false);
                player.seekFraction(v);
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(current),
                style: const TextStyle(color: Colors.white),
              ),
              Text(_format(total), style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ===== Các nút điều khiển =====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: isShuffle ? Colors.green : Colors.white,
              ),
              onPressed: _toggleShuffle,
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 36),
              onPressed: () {
                // TODO: thêm logic prev nếu cần
              },
            ),
            const SizedBox(width: 10),
            ScaleTransition(
              scale: _scaleAnimation,
              child: IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 64,
                  color: Colors.green,
                ),
                onPressed: () async {
                  if (isPlaying) {
                    player.pause();
                    _playController.reverse();
                  } else {
                    debugPrint("🎵 Phát từ URL: ${widget.song.audioUrl}");
                    await player.playSong(widget.song.audioUrl);
                    _playController.forward();
                  }
                  setState(() => isPlaying = player.isPlaying);
                },
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.skip_next, size: 36),
              onPressed: () {
                // TODO: thêm logic next nếu cần
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                color: repeatMode == 0 ? Colors.white : Colors.green,
              ),
              onPressed: _toggleRepeat,
            ),
          ],
        ),
      ],
    );
  }
}
