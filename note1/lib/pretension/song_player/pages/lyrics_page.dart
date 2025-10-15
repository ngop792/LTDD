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
  late AnimationController _glowController;
  late AnimationController _playController;
  late Animation<double> _scaleAnimation;

  final MusicPlayer player = MusicPlayer.instance;

  Timer? _localTimerForScroll;
  late VoidCallback _playerListener;

  bool isFavorite = false; // ✅ Thêm biến để quản lý trái tim

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _playController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _playController, curve: Curves.easeInOut),
    );

    _playerListener = () {
      if (mounted) setState(() {});
    };
    player.addListener(_playerListener);

    player.setTotal(const Duration(minutes: 4, seconds: 20));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLyric();
    });
  }

  void _scrollToCurrentLyric() {
    if (widget.currentIndex < widget.lyrics.length &&
        _scrollController.hasClients) {
      _scrollController.animateTo(
        widget.currentIndex * 50.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    _playController.dispose();
    _localTimerForScroll?.cancel();
    _scrollController.dispose();
    player.removeListener(_playerListener);
    super.dispose();
  }

  String _formatDuration(double seconds) {
    int minutes = (seconds ~/ 60);
    int secs = (seconds % 60).toInt();
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
        widget.imageUrl.isNotEmpty && widget.imageUrl.startsWith("http");

    if (player.isPlaying) {
      if (!_rotationController.isAnimating) _rotationController.repeat();
    } else {
      if (_rotationController.isAnimating) _rotationController.stop();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.songTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: isNetworkImage
                ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                : (widget.imageUrl.isNotEmpty
                      ? Image.asset(widget.imageUrl, fit: BoxFit.cover)
                      : Container(color: Colors.black)),
          ),

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

          Center(
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) => Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: child,
              ),
              child: Opacity(
                opacity: 0.12,
                child: ClipOval(
                  child: isNetworkImage
                      ? Image.network(
                          widget.imageUrl,
                          width: 260,
                          height: 260,
                          fit: BoxFit.cover,
                        )
                      : (widget.imageUrl.isNotEmpty
                            ? Image.asset(
                                widget.imageUrl,
                                width: 260,
                                height: 260,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(width: 260, height: 260)),
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: player,
            builder: (context, _) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: 120,
                  horizontal: 20,
                ),
                itemCount: widget.lyrics.length,
                itemBuilder: (context, index) {
                  final isActive = index == widget.currentIndex;
                  return AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: isActive ? 22 : 16,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive ? Colors.greenAccent : Colors.white70,
                      shadows: isActive
                          ? [
                              const Shadow(
                                blurRadius: 8,
                                color: Colors.greenAccent,
                              ),
                            ]
                          : [],
                    ),
                    child: AnimatedScale(
                      scale: isActive ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 300),
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
              );
            },
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: player,
              builder: (context, _) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            ClipOval(
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
                            const SizedBox(width: 12),
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
                            // ✅ Sửa đúng phần này
                            ValueListenableBuilder<Color>(
                              valueListenable: AppColors.primary,
                              builder: (context, color, _) => AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: 1.0,
                                child: IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.redAccent
                                        : Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Column(
                          children: [
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
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(player.total),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ValueListenableBuilder<Color>(
                              valueListenable: AppColors.primary,
                              builder: (context, color, _) => IconButton(
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Icon(
                                    Icons.shuffle,
                                    key: ValueKey(player.isShuffle),
                                    color: player.isShuffle
                                        ? color
                                        : Colors.grey.shade600,
                                    size: 28,
                                  ),
                                ),
                                onPressed: () => player.toggleShuffle(),
                              ),
                            ),

                            const Icon(Icons.skip_previous, size: 36),

                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: ValueListenableBuilder<Color>(
                                valueListenable: AppColors.primary,
                                builder: (context, color, _) => IconButton(
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
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

                            const Icon(Icons.skip_next, size: 36),

                            ValueListenableBuilder<Color>(
                              valueListenable: AppColors.primary,
                              builder: (context, color, _) {
                                final activeColor = player.repeatMode == 0
                                    ? Colors.grey.shade600
                                    : color;
                                return IconButton(
                                  onPressed: () => player.toggleRepeat(),
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      key: ValueKey(player.repeatMode),
                                      children: [
                                        Icon(
                                          Icons.repeat,
                                          color: activeColor,
                                          size: 28,
                                        ),
                                        if (player.repeatMode == 2)
                                          Positioned(
                                            bottom: 6,
                                            child: Text(
                                              "1",
                                              style: TextStyle(
                                                color: activeColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
