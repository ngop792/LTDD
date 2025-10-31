import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/song_player/pages/music_player.dart';

class LyricPage extends StatefulWidget {
  final String songTitle;
  final String artist;
  final String imageUrl;
  final List<String> lyrics;
  final int currentIndex;

  const LyricPage({
    super.key,
    required this.songTitle,
    required this.artist,
    required this.imageUrl,
    required this.lyrics,
    this.currentIndex = 0,
  });

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _rotationController;
  late AnimationController _playController;
  late Animation<double> _scaleAnimation;

  final MusicPlayer player = MusicPlayer.instance;

  Timer? _scrollTimer;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );

    _playController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _playController, curve: Curves.easeInOut),
    );

    player.addListener(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged() {
    if (mounted) setState(() {});
    if (player.isPlaying) {
      if (!_rotationController.isAnimating) _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    player.removeListener(_onPlayerStateChanged);
    _rotationController.dispose();
    _playController.dispose();
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds ~/ 60);
    final secs = (seconds % 60).toInt();
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

  bool get isPlaying => player.isPlaying;

  void _togglePlay() {
    setState(() {
      player.togglePlay();
      if (player.isPlaying) {
        _playController.forward();
      } else {
        _playController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        widget.imageUrl.isNotEmpty && widget.imageUrl.startsWith('http');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.songTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// --- ẢNH NỀN ---
          Positioned.fill(
            child: isNetworkImage
                ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                : (widget.imageUrl.isNotEmpty
                      ? Image.asset(widget.imageUrl, fit: BoxFit.cover)
                      : Container(color: Colors.black)),
          ),

          /// --- LỚP MỜ ---
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.black54, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          /// --- VÒNG ĐĨA XOAY ---
          Center(
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) => Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: child,
              ),
              child: Opacity(
                opacity: 0.15,
                child: ClipOval(
                  child: isNetworkImage
                      ? Image.network(
                          widget.imageUrl,
                          width: 240,
                          height: 240,
                          fit: BoxFit.cover,
                        )
                      : (widget.imageUrl.isNotEmpty
                            ? Image.asset(
                                widget.imageUrl,
                                width: 240,
                                height: 240,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(width: 240, height: 240)),
                ),
              ),
            ),
          ),

          /// --- LỜI BÀI HÁT ---
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 120, bottom: 220),
            itemCount: widget.lyrics.length,
            itemBuilder: (context, index) {
              final isActive = index == widget.currentIndex;
              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isActive ? 22 : 16,
                  color: isActive ? Colors.greenAccent : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      widget.lyrics[index],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),

          /// --- THANH ĐIỀU KHIỂN DƯỚI ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// --- Tiêu đề + Trái tim ---
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: isNetworkImage
                              ? Image.network(
                                  widget.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : (widget.imageUrl.isNotEmpty
                                    ? Image.asset(
                                        widget.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade300,
                                      )),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.songTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.artist,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.redAccent : Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => isFavorite = !isFavorite),
                        ),
                      ],
                    ),

                    /// --- Thanh tiến trình ---
                    Slider(
                      value: player.current.clamp(0.0, player.total),
                      min: 0,
                      max: player.total > 0 ? player.total : 1,
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (v) => player.setCurrentSeconds(v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(player.current),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          _formatDuration(player.total),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    /// --- Nút điều khiển ---
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: player.isShuffle
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () => player.toggleShuffle(),
                        ),
                        const Icon(Icons.skip_previous, size: 36),
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
                            onPressed: _togglePlay,
                          ),
                        ),
                        const Icon(Icons.skip_next, size: 36),
                        IconButton(
                          icon: Icon(
                            player.repeatMode == 0
                                ? Icons.repeat
                                : (player.repeatMode == 1
                                      ? Icons.repeat_one
                                      : Icons.repeat_on),
                            color: player.repeatMode == 0
                                ? Colors.grey
                                : Colors.green,
                          ),
                          onPressed: () => player.toggleRepeat(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
