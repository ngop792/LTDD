import 'package:flutter/material.dart';
import 'package:note1/domain/entities/simple_songs.dart';

class PlayerController {
  // singleton (1 instance duy nhất cho toàn app)
  static final PlayerController _instance = PlayerController._internal();
  factory PlayerController() => _instance;
  PlayerController._internal();

  // bài hát hiện tại
  final ValueNotifier<SimpleSong?> currentSong = ValueNotifier(null);

  // trạng thái đang phát
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  // chọn bài
  void setSong(SimpleSong song) {
    currentSong.value = song;
    isPlaying.value = true;
  }

  // play/pause
  void togglePlay() {
    isPlaying.value = !isPlaying.value;
  }

  // dừng hẳn
  void stop() {
    isPlaying.value = false;
    currentSong.value = null;
  }
}
