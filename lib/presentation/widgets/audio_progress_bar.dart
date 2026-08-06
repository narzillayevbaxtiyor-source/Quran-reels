/// Audio progress bar widget with play/pause controls.
///
/// Displays a seekable progress bar with play/pause toggle
/// and loading indicator for audio playback.
library;

import 'package:flutter/material.dart';

/// A custom audio progress bar with built-in play/pause button.
class AudioProgressBar extends StatelessWidget {
  /// Whether audio is currently playing.
  final bool isPlaying;

  /// Whether audio is currently loading.
  final bool isLoading;

  /// Current playback progress (0.0 to 1.0).
  final double progress;

  /// Called when the play/pause button is tapped.
  final VoidCallback? onPlayPause;

  /// Called when the user seeks to a new position.
  final void Function(Duration position)? onSeek;

  const AudioProgressBar({
    super.key,
    required this.isPlaying,
    this.isLoading = false,
    this.progress = 0.0,
    this.onPlayPause,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Play/Pause button
          _PlayPauseButton(
            isPlaying: isPlaying,
            isLoading: isLoading,
            onTap: onPlayPause,
          ),
          const SizedBox(width: 8),
          // Progress bar
          Expanded(
            child: _ProgressTrack(
              progress: progress,
              onSeek: onSeek,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// Circular play/pause button.
class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    key: ValueKey(isPlaying),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Seekable progress track.
class _ProgressTrack extends StatelessWidget {
  final double progress;
  final void Function(Duration position)? onSeek;

  _ProgressTrack({required this.progress, this.onSeek});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        return GestureDetector(
          onTapDown: (details) {
            if (onSeek != null) {
              final tapPosition = details.localPosition.dx;
              final fraction = (tapPosition / trackWidth).clamp(0.0, 1.0);
              onSeek!(Duration(milliseconds: (fraction * 10000).toInt()));
            }
          },
          child: Container(
            height: 32,
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Filled track
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF66BB6A),
                          Color(0xFFFFD700),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: progress * trackWidth - 6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
