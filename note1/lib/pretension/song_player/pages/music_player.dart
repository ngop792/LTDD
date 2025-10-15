// lib/pretension/song_player/bloc/music_player.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class MusicPlayer extends ChangeNotifier {
  MusicPlayer._internal();
  static final MusicPlayer instance = MusicPlayer._internal();

  bool _isPlaying = false;
  double _current = 0.0; // seconds
  double _total = 240.0; // seconds default, can set per track
  bool _isShuffle = false;
  int _repeatMode = 0; // 0 = off, 1 = repeat all, 2 = repeat one

  Timer? _timer;

  // getters
  bool get isPlaying => _isPlaying;
  double get current => _current;
  double get total => _total;
  bool get isShuffle => _isShuffle;
  int get repeatMode => _repeatMode;

  // set total (call when new song loaded)
  void setTotal(Duration d) {
    _total = d.inSeconds.toDouble();
    if (_current > _total) _current = 0;
    notifyListeners();
  }

  // set current position (seconds)
  void setCurrentSeconds(double seconds) {
    _current = seconds.clamp(0.0, _total);
    notifyListeners();
  }

  // toggle play/pause
  void togglePlay() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTimer();
    } else {
      _stopTimer();
    }
    notifyListeners();
  }

  void play() {
    if (!_isPlaying) togglePlay();
  }

  void pause() {
    if (_isPlaying) togglePlay();
  }

  // internal timer simulating playback
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPlaying) return;
      if (_current < _total) {
        _current += 1;
      } else {
        // track ended
        if (_repeatMode == 2) {
          // repeat one
          _current = 0;
        } else {
          // stop or repeat all
          if (_repeatMode == 1) {
            _current = 0;
          } else {
            _isPlaying = false;
            _stopTimer();
          }
        }
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // toggle shuffle
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  // cycle repeat mode 0 -> 1 -> 2 -> 0
  void toggleRepeat() {
    _repeatMode = (_repeatMode + 1) % 3;
    notifyListeners();
  }

  // seek to fraction (0..1)
  void seekFraction(double fraction) {
    double newSec = (fraction.clamp(0.0, 1.0) * _total);
    setCurrentSeconds(newSec);
  }

  // optional: stop and clear resources
  void disposePlayer() {
    _stopTimer();
  }
}
