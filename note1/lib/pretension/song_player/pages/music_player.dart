import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class MusicPlayer extends ChangeNotifier {
  // Singleton pattern để dùng chung 1 trình phát toàn app
  MusicPlayer._internal();
  static final MusicPlayer instance = MusicPlayer._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ====== TRẠNG THÁI PHÁT ======
  bool _isPlaying = false;
  double _current = 0.0;
  double _total = 0.0;
  bool _isShuffle = false;
  int _repeatMode = 0; // 0 = off, 1 = all, 2 = one

  // ====== GETTERS ======
  bool get isPlaying => _isPlaying;
  double get current => _current;
  double get total => _total;
  bool get isShuffle => _isShuffle;
  int get repeatMode => _repeatMode;
  AudioPlayer get audioPlayer => _audioPlayer;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  // =====================================================
  // ✅ PHÁT BÀI HÁT TỪ URL
  // =====================================================
  Future<void> playSong(String url) async {
    try {
      // Hủy đăng ký stream cũ (tránh nhân đôi listener)
      await _cancelStreams();

      await _audioPlayer.stop();

      final duration = await _audioPlayer.setUrl(url);

      if (duration == null) {
        if (kDebugMode) print("⚠️ Không thể tải bài hát từ: $url");
        return;
      }

      _total = duration.inSeconds.toDouble();
      _current = 0;
      _isPlaying = true;

      await _audioPlayer.play();

      _listenStreams();

      notifyListeners();
      if (kDebugMode) print("🎵 Đang phát: $url");
    } catch (e) {
      if (kDebugMode) print("❌ Lỗi khi phát nhạc: $e");
    }
  }

  // =====================================================
  // ✅ LẮNG NGHE STREAMS
  // =====================================================
  void _listenStreams() {
    _positionSub = _audioPlayer.positionStream.listen((pos) {
      _current = pos.inSeconds.toDouble();
      notifyListeners();
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        _total = dur.inSeconds.toDouble();
        notifyListeners();
      }
    });

    _stateSub = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  Future<void> _cancelStreams() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _stateSub?.cancel();
  }

  // =====================================================
  // ✅ PHÁT / TẠM DỪNG / TIẾP TỤC
  // =====================================================
  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void pause() {
    _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() {
    _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  // =====================================================
  // ✅ SEEK BẰNG TỈ LỆ THANH TRƯỢT (0.0 – 1.0)
  // =====================================================
  void seekFraction(double fraction) {
    if (_total <= 0) return;
    final newPos = Duration(seconds: (_total * fraction).round());
    _audioPlayer.seek(newPos);
    _current = newPos.inSeconds.toDouble();
    notifyListeners();
  }

  // =====================================================
  // ✅ TUA NHẠC THEO GIÂY
  // =====================================================
  Future<void> setCurrentSeconds(double seconds) async {
    if (_total <= 0) return;
    try {
      await _audioPlayer.seek(Duration(seconds: seconds.toInt()));
      _current = seconds;
      notifyListeners();
      if (kDebugMode) print("⏩ Tua đến $seconds giây");
    } catch (e) {
      if (kDebugMode) print("❌ Lỗi tua nhạc: $e");
    }
  }

  // =====================================================
  // ✅ NGẪU NHIÊN / LẶP LẠI
  // =====================================================
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _audioPlayer.setShuffleModeEnabled(_isShuffle);
    notifyListeners();
  }

  void toggleRepeat() {
    _repeatMode = (_repeatMode + 1) % 3;

    _audioPlayer.setLoopMode(
      _repeatMode == 2
          ? LoopMode.one
          : (_repeatMode == 1 ? LoopMode.all : LoopMode.off),
    );

    notifyListeners();
  }

  // =====================================================
  // ✅ GIẢI PHÓNG TÀI NGUYÊN
  // =====================================================
  @override
  void dispose() {
    _cancelStreams();
    _audioPlayer.dispose();
    super.dispose();
  }

  void disposePlayer() {
    dispose();
  }
}
