import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MusicPlayer extends ChangeNotifier {
  // Singleton
  MusicPlayer._internal();
  static final MusicPlayer instance = MusicPlayer._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ====== Trạng thái phát ======
  bool _isPlaying = false;
  double _current = 0.0;
  double _total = 0.0;
  bool _isShuffle = false;
  int _repeatMode = 0; // 0 = off, 1 = all, 2 = one

  // ====== Getters ======
  bool get isPlaying => _isPlaying;
  double get current => _current;
  double get total => _total;
  bool get isShuffle => _isShuffle;
  int get repeatMode => _repeatMode;
  AudioPlayer get audioPlayer => _audioPlayer;

  // ====== Stream Subscriptions ======
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  // =====================================================
  // ✅ Phát nhạc từ URL hoặc CSDL
  // =====================================================
  Future<void> playSong(String url, {String? filename}) async {
    try {
      // Hủy stream cũ
      await _cancelStreams();
      await _audioPlayer.stop();

      // Kiểm tra HTTP/HTTPS
      if (url.startsWith('http://')) {
        if (kDebugMode) {
          print(
            "⚠️ URL sử dụng HTTP không mã hóa. "
            "Android 9+ cần android:usesCleartextTraffic=\"true\" hoặc network_security_config.",
          );
        }
      }

      // Download file về local nếu filename được cung cấp
      String path = url;
      if (filename != null) {
        path = await _downloadFile(url, filename);
        if (kDebugMode) print("🎵 File đã tải về: $path");
      }

      // Set file path hoặc URL
      final duration = filename != null
          ? await _audioPlayer.setFilePath(path)
          : await _audioPlayer.setUrl(url);

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
      if (kDebugMode) {
        print("❌ Lỗi khi phát nhạc: $e");
        if (e.toString().contains("Cleartext")) {
          print(
            "⚠️ Lỗi Cleartext HTTP traffic. "
            "Hãy bật usesCleartextTraffic=true hoặc dùng HTTPS.",
          );
        }
      }
    }
  }

  // =====================================================
  // ✅ Tải file về local
  // =====================================================
  Future<String> _downloadFile(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Không tải được file');

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename.mp3');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  // =====================================================
  // ✅ Lắng nghe streams
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

    // Optional: debug event stream
    _audioPlayer.playbackEventStream.listen(
      (event) {
        if (kDebugMode) print("Event: $event");
      },
      onError: (e, st) {
        if (kDebugMode) print("Playback error: $e");
      },
    );
  }

  Future<void> _cancelStreams() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _stateSub?.cancel();
  }

  // =====================================================
  // ✅ Play / Pause / Resume
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
  // ✅ Seek
  // =====================================================
  void seekFraction(double fraction) {
    if (_total <= 0) return;
    final newPos = Duration(seconds: (_total * fraction).round());
    _audioPlayer.seek(newPos);
    _current = newPos.inSeconds.toDouble();
    notifyListeners();
  }

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
  // ✅ Shuffle / Repeat
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
  // ✅ Dispose
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
