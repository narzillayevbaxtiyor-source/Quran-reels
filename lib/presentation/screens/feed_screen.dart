/// Main feed screen with infinite vertical scrolling Quran verses.
///
/// The core experience of the app - TikTok-like vertical swiping
/// through Quran verses with audio playback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feed_provider.dart';
import '../widgets/verse_card.dart';
import '../widgets/tafsir_overlay.dart';

/// Infinite vertical feed screen displaying Quran verses.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final feedState = ref.read(feedProvider);
    if (index > feedState.currentIndex) {
      ref.read(feedProvider.notifier).nextVerse();
    } else {
      ref.read(feedProvider.notifier).previousVerse();
    }
  }

  void _showTafsir() {
    final verse = ref.read(feedProvider).currentVerseItem;
    if (verse == null) return;

    TafsirOverlay.show(context, verse);
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    if (feedState.status == FeedStatus.loading) {
      return _buildLoadingScreen();
    }

    if (feedState.status == FeedStatus.error) {
      return _buildErrorScreen(feedState.errorMessage ?? '');
    }

    if (feedState.verses.isEmpty) {
      return _buildEmptyScreen();
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: feedState.verses.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final verse = feedState.verses[index];
        final isActive = index == feedState.currentIndex;

        return VerseCard(
          verse: verse,
          isActive: isActive,
          onLongPress: _showTafsir,
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D2612),
            Color(0xFF1B5E20),
            Color(0xFF0D2612),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Oyatlar yuklanmoqda...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String errorMessage) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D2612),
            Color(0xFF1B5E20),
            Color(0xFF0D2612),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(feedProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Qayta urinish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D2612),
            Color(0xFF1B5E20),
            Color(0xFF0D2612),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book,
              color: Colors.white38,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oyatlar mavjud emas',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
