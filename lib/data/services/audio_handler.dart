import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

enum PlayerRepeatMode { off, one, all }

class MusicAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _queue = [];
  int _currentIndex = 0;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.off;
  bool _shuffle = false;
  List<int> _playOrder = [];

  AudioPlayer get player => _player;
  PlayerRepeatMode get repeatMode => _repeatMode;
  bool get shuffleEnabled => _shuffle;
  Song? get currentSong => _queue.isEmpty ? null : _queue[_currentIndex];

  MusicAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleCompletion();
      }
    });
  }

  Future<void> loadQueue(List<Song> songs, int startIndex) async {
    _queue = songs;
    _currentIndex = startIndex;
    _playOrder = List.generate(songs.length, (i) => i);
    if (_shuffle) _shufflePlayOrder(keepCurrentFirst: true);
    queue.add(songs.map(_songToMediaItem).toList());
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    if (_queue.isEmpty) return;
    final song = _queue[_currentIndex];
    mediaItem.add(_songToMediaItem(song));
    await _player.setFilePath(song.filePath);
    await _player.play();
  }

  void _shufflePlayOrder({bool keepCurrentFirst = false}) {
    _playOrder = List.generate(_queue.length, (i) => i);
    _playOrder.shuffle();
    if (keepCurrentFirst) {
      _playOrder.remove(_currentIndex);
      _playOrder.insert(0, _currentIndex);
    }
  }

  void _handleCompletion() {
    if (_repeatMode == PlayerRepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
      return;
    }
    skipToNext();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    final pos = _playOrder.indexOf(_currentIndex);
    if (pos + 1 < _playOrder.length) {
      _currentIndex = _playOrder[pos + 1];
      await _playCurrent();
    } else if (_repeatMode == PlayerRepeatMode.all) {
      _currentIndex = _playOrder.first;
      await _playCurrent();
    } else {
      await _player.pause();
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    final pos = _playOrder.indexOf(_currentIndex);
    if (pos - 1 >= 0) {
      _currentIndex = _playOrder[pos - 1];
      await _playCurrent();
    } else if (_repeatMode == PlayerRepeatMode.all) {
      _currentIndex = _playOrder.last;
      await _playCurrent();
    }
  }

  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    if (_shuffle) {
      _shufflePlayOrder(keepCurrentFirst: true);
    } else {
      _playOrder = List.generate(_queue.length, (i) => i);
    }
  }

  void cyclePlayerRepeatMode() {
    switch (_repeatMode) {
      case PlayerRepeatMode.off:
        _repeatMode = PlayerRepeatMode.all;
        break;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
        break;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.off;
        break;
    }
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.id.toString(),
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      extras: {'filePath': song.filePath},
    );
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      speed: _player.speed,
    ));
  }
}
