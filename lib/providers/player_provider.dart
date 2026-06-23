import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/song.dart';
import '../data/services/audio_handler.dart';

class PlayerProvider extends ChangeNotifier {
  final MusicAudioHandler audioHandler;

  Duration position = Duration.zero;
  Duration? duration;
  bool isPlaying = false;
  double speed = 1.0;

  Timer? _sleepTimer;
  DateTime? _sleepTimerEndTime;

  PlayerProvider(this.audioHandler) {
    audioHandler.positionStream.listen((p) {
      position = p;
      notifyListeners();
    });
    audioHandler.durationStream.listen((d) {
      duration = d;
      notifyListeners();
    });
    audioHandler.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });
  }

  Song? get currentSong => audioHandler.currentSong;
  PlayerRepeatMode get repeatMode => audioHandler.repeatMode;
  bool get shuffleEnabled => audioHandler.shuffleEnabled;

  Future<void> playQueue(List<Song> songs, int startIndex) =>
      audioHandler.loadQueue(songs, startIndex);

  Future<void> togglePlayPause() {
    return isPlaying ? audioHandler.pause() : audioHandler.play();
  }

  Future<void> next() => audioHandler.skipToNext();
  Future<void> previous() => audioHandler.skipToPrevious();
  Future<void> seek(Duration pos) => audioHandler.seek(pos);

  Future<void> toggleShuffle() async {
    await audioHandler.toggleShuffle();
    notifyListeners();
  }

  void cycleRepeat() {
    audioHandler.cyclePlayerRepeatMode();
    notifyListeners();
  }

  Future<void> setSpeed(double newSpeed) async {
    speed = newSpeed;
    await audioHandler.setSpeed(newSpeed);
    notifyListeners();
  }

  DateTime? get sleepTimerEndTime => _sleepTimerEndTime;
  bool get hasSleepTimer => _sleepTimer != null;

  void setSleepTimerDuration(Duration delay) {
    _startSleepTimer(DateTime.now().add(delay));
  }

  void setSleepTimerAt(DateTime clockTime) {
    final now = DateTime.now();
    final target = clockTime.isAfter(now)
        ? clockTime
        : clockTime.add(const Duration(days: 1));
    _startSleepTimer(target);
  }

  void _startSleepTimer(DateTime endTime) {
    _sleepTimer?.cancel();
    _sleepTimerEndTime = endTime;
    _sleepTimer = Timer(endTime.difference(DateTime.now()), () {
      audioHandler.pause();
      _sleepTimer = null;
      _sleepTimerEndTime = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerEndTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }
}
