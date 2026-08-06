/// Audio playback service using just_audio for Quran recitations.
///
/// Provides streaming audio playback with controls for:
/// - Play, pause, stop
/// - Seeking
/// - Playback speed adjustment
/// - Reciter selection
library;

import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

/// Service class for handling Quran audio playback.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  /// The current playback state.
  PlayerState get playerState => _player.playerState;

  /// Stream of playback states.
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// The current playback position.
  Duration get position => _player.position;

  /// Stream of position changes.
  Stream<Duration> get positionStream => _player.positionStream;

  /// The total duration of the loaded audio.
  Duration? get duration => _player.duration;

  /// Stream of duration changes.
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Whether audio is currently playing.
  bool get isPlaying => _player.playing;

  /// Current playback speed.
  double get speed => _player.speed;

  /// Current reciter identifier.
  String _currentReciter = AppConstants.defaultReciter;
  String get currentReciter => _currentReciter;

  /// Callback when audio completes.
  void Function()? onAudioComplete;

  /// Callback for position updates.
  void Function(Duration position, Duration? duration)? onPositionChanged;

  /// Callback for player state changes.
  void Function(PlayerState state)? onPlayerStateChanged;

  /// Initializes the audio service with stream listeners.
  Future<void> initialize() async {
    _player.setSpeed(AppConstants.defaultPlaybackSpeed);

    _playerStateSubscription = _player.playerStateStream.listen((state) {
      onPlayerStateChanged?.call(state);
      if (state.processingState == ProcessingState.completed) {
        onAudioComplete?.call();
      }
    });

    _positionSubscription = _player.positionStream.listen((position) {
      onPositionChanged?.call(position, _player.duration);
    });
  }

  /// Loads and plays an audio URL.
  ///
  /// [url] - The audio URL to stream.
  /// Returns [ApiResult.success] if playback started successfully.
  Future<ApiResult<bool>> play(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(
        AudioFailure(
          message: 'Audio ijro etishda xatolik',
          technicalMessage: e.toString(),
        ),
      );
    }
  }

  /// Loads and plays audio from an asset.
  Future<ApiResult<bool>> playAsset(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      await _player.play();
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(
        AudioFailure(message: 'Audio fayl yuklashda xatolik'),
      );
    }
  }

  /// Pauses the current playback.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resumes paused playback.
  Future<void> resume() async {
    await _player.play();
  }

  /// Toggles between play and pause.
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Stops playback and releases resources.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seeks to a specific position in the audio.
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Seeks forward by [seconds].
  Future<void> seekForward({int seconds = 10}) async {
    final newPosition = _player.position + Duration(seconds: seconds);
    final maxDuration = _player.duration ?? Duration.zero;
    await _player.seek(
      newPosition > maxDuration ? maxDuration : newPosition,
    );
  }

  /// Seeks backward by [seconds].
  Future<void> seekBackward({int seconds = 10}) async {
    final newPosition = _player.position - Duration(seconds: seconds);
    await _player.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  /// Sets the playback speed.
  Future<void> setSpeed(double speed) async {
    final clamped =
        speed.clamp(AppConstants.minPlaybackSpeed, AppConstants.maxPlaybackSpeed);
    await _player.setSpeed(clamped);
  }

  /// Sets the current reciter.
  void setReciter(String reciter) {
    _currentReciter = reciter;
  }

  /// Builds the audio URL for a specific verse and reciter.
  String buildVerseAudioUrl(int surah, int verse, {String? reciter}) {
    final rec = reciter ?? _currentReciter;
    final paddedSurah = surah.toString().padLeft(3, '0');
    final paddedVerse = verse.toString().padLeft(3, '0');
    return 'https://cdn.islamic.network/quran/audio/128/$rec/$paddedSurah$paddedVerse.mp3';
  }

  /// Disposes of all resources.
  Future<void> dispose() async {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    await _player.dispose();
  }
}
