/// Audio playback state provider.
///
/// Manages audio playback state including current verse,
/// play/pause, position tracking, and reciter selection.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/quran_models.dart';
import '../../data/services/audio_service.dart';

/// Audio playback state.
class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration? duration;
  final String currentVerseId;
  final String currentReciter;
  final double playbackSpeed;
  final String? errorMessage;
  final List<ReciterModel> reciters;

  const AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration,
    this.currentVerseId = '',
    this.currentReciter = AppConstants.defaultReciter,
    this.playbackSpeed = AppConstants.defaultPlaybackSpeed,
    this.errorMessage,
    this.reciters = const [],
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    String? currentVerseId,
    String? currentReciter,
    double? playbackSpeed,
    String? errorMessage,
    List<ReciterModel>? reciters,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentVerseId: currentVerseId ?? this.currentVerseId,
      currentReciter: currentReciter ?? this.currentReciter,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      errorMessage: errorMessage,
      reciters: reciters ?? this.reciters,
    );
  }

  /// Progress as a fraction (0.0 to 1.0).
  double get progress => duration != null && duration!.inMilliseconds > 0
      ? position.inMilliseconds / duration!.inMilliseconds
      : 0.0;
}

/// Provider for audio state.
final audioProvider =
    StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});

/// Notifier for audio playback management.
class AudioNotifier extends StateNotifier<AudioState> {
  final AudioService _audioService = AudioService();

  AudioNotifier() : super(const AudioState()) {
    _initializeAudio();
  }

  /// Sets up audio service listeners.
  void _initializeAudio() {
    _audioService.initialize();

    _audioService.onPositionChanged = (position, duration) {
      if (mounted) {
        state = state.copyWith(position: position, duration: duration);
      }
    };

    _audioService.onAudioComplete = () {
      if (mounted) {
        state = state.copyWith(isPlaying: false);
      }
    };
  }

  /// Plays audio for a specific verse.
  Future<void> playVerse(int surah, int verse) async {
    final verseId = '$surah:$verse';
    state = state.copyWith(isLoading: true, currentVerseId: verseId);

    final url = _audioService.buildVerseAudioUrl(surah, verse);
    final result = await _audioService.play(url);

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(isPlaying: true, isLoading: false);
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Toggles play/pause.
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _audioService.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      await _audioService.resume();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Stops playback.
  Future<void> stop() async {
    await _audioService.stop();
    state = state.copyWith(isPlaying: false, position: Duration.zero);
  }

  /// Seeks to a position.
  Future<void> seekTo(Duration position) async {
    await _audioService.seek(position);
  }

  /// Sets playback speed.
  Future<void> setSpeed(double speed) async {
    await _audioService.setSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  /// Sets the reciter.
  void setReciter(String identifier) {
    _audioService.setReciter(identifier);
    state = state.copyWith(currentReciter: identifier);
  }

  /// Loads available reciters.
  void setReciters(List<ReciterModel> reciters) {
    state = state.copyWith(reciters: reciters);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
