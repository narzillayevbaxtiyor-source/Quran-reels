/// Full-screen verse card widget for the vertical feed.
///
/// Displays a Quran verse with:
/// - Background image
/// - Arabic text in Uthmani font
/// - Uzbek translation
/// - Surah name and verse number
/// - Play/Pause button
/// - Audio progress bar
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/verse.dart';
import '../providers/audio_provider.dart';
import '../providers/feed_provider.dart';
import 'audio_progress_bar.dart';

/// A full-screen card displaying a single Quran verse.
///
/// Used in the vertical paging feed. Each card shows the Arabic text,
/// translation, and media controls.
class VerseCard extends ConsumerStatefulWidget {
  /// The verse to display.
  final Verse verse;

  /// Whether this card is active (visible).
  final bool isActive;

  /// Callback when the user double-taps to favorite.
  final VoidCallback? onDoubleTap;

  /// Callback when the user long-presses for tafsir.
  final VoidCallback? onLongPress;

  const VerseCard({
    super.key,
    required this.verse,
    this.isActive = true,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  ConsumerState<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends ConsumerState<VerseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;

  bool _showHeartOverlay = false;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(VerseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _playCurrentVerse();
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _playCurrentVerse() {
    ref.read(audioProvider.notifier).playVerse(
          widget.verse.surahNumber,
          widget.verse.number,
        );
  }

  void _handleDoubleTap() {
    // Show heart animation
    setState(() => _showHeartOverlay = true);
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse().then((_) {
        if (mounted) {
          setState(() => _showHeartOverlay = false);
        }
      });
    });

    // Toggle favorite
    ref.read(feedProvider.notifier).toggleFavoriteOnCurrent();
    widget.onDoubleTap?.call();
  }

  void _handleTogglePlayPause() {
    ref.read(audioProvider.notifier).togglePlayPause();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioState = ref.watch(audioProvider);

    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      onLongPress: widget.onLongPress,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildBackground(),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Surah info
                    _buildSurahHeader(theme),
                    const Spacer(),
                    // Arabic text
                    Expanded(
                      flex: 5,
                      child: _buildArabicText(theme),
                    ),
                    const Spacer(),
                    // Translation
                    _buildTranslation(theme),
                    const SizedBox(height: 24),
                    // Surah name and verse number
                    _buildVerseReference(theme),
                    const Spacer(flex: 2),
                    // Audio controls
                    _buildAudioControls(theme, audioState),
                    const SizedBox(height: 24),
                    // Bottom action buttons
                    _buildActionRow(theme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // Heart overlay animation
              if (_showHeartOverlay)
                Center(
                  child: ScaleTransition(
                    scale: _heartScaleAnimation,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackground() {
    // Beautiful gradient background with Islamic patterns feel
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D2612),
          const Color(0xFF1B5E20).withOpacity(0.9),
          const Color(0xFF2E7D32).withOpacity(0.8),
          const Color(0xFF0D2612),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  Widget _buildSurahHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            widget.verse.surahNameArabic,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Uthmani',
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArabicText(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Text(
            widget.verse.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 26,
              height: 2.0,
              color: Colors.white,
              fontFamily: 'Uthmani',
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTranslation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.verse.translation,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildVerseReference(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.secondaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '${widget.verse.surahNameUzbek} • ${widget.verse.surahNumber}:${widget.verse.number}',
            style: TextStyle(
              color: AppTheme.secondaryColor.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioControls(ThemeData theme, AudioState audioState) {
    final isCurrentVerse = audioState.currentVerseId == widget.verse.id;

    return AudioProgressBar(
      isPlaying: audioState.isPlaying && isCurrentVerse,
      isLoading: audioState.isLoading && isCurrentVerse,
      progress: isCurrentVerse ? audioState.progress : 0.0,
      onPlayPause: _handleTogglePlayPause,
      onSeek: (position) {
        if (isCurrentVerse) {
          ref.read(audioProvider.notifier).seekTo(position);
        }
      },
    );
  }

  Widget _buildActionRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: widget.verse.isFavorite
              ? Icons.favorite
              : Icons.favorite_border,
          color: widget.verse.isFavorite ? Colors.red : Colors.white70,
          label: 'Saralash',
          onTap: _handleDoubleTap,
        ),
        _ActionButton(
          icon: widget.verse.isBookmarked
              ? Icons.bookmark
              : Icons.bookmark_border,
          color: widget.verse.isBookmarked
              ? AppTheme.secondaryColor
              : Colors.white70,
          label: 'Xatcho\'p',
          onTap: () {
            ref.read(feedProvider.notifier).toggleBookmarkOnCurrent();
          },
        ),
        _ActionButton(
          icon: Icons.share_rounded,
          color: Colors.white70,
          label: 'Ulashish',
          onTap: () {
            // Share functionality
          },
        ),
        _ActionButton(
          icon: Icons.translate,
          color: Colors.white70,
          label: 'Tafsir',
          onTap: widget.onLongPress ?? () {},
        ),
      ],
    );
  }
}

/// Small action button used in the verse card action row.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
