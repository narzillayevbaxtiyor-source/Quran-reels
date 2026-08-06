/// Feed state and provider for the infinite vertical scrolling feed.
///
/// Manages the queue of verses, current verse index, loading states,
/// and infinite scrolling pagination.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/quran_repository.dart';
import '../../domain/entities/verse.dart';
import '../../di/injection_container.dart';

/// Represents the current loading state of the feed.
enum FeedStatus { initial, loading, loaded, error }

/// State class for the feed.
class FeedState {
  final List<Verse> verses;
  final int currentIndex;
  final FeedStatus status;
  final String? errorMessage;
  final int currentSurah;
  final int currentVerse;

  const FeedState({
    this.verses = const [],
    this.currentIndex = 0,
    this.status = FeedStatus.initial,
    this.errorMessage,
    this.currentSurah = 1,
    this.currentVerse = 1,
  });

  FeedState copyWith({
    List<Verse>? verses,
    int? currentIndex,
    FeedStatus? status,
    String? errorMessage,
    int? currentSurah,
    int? currentVerse,
  }) {
    return FeedState(
      verses: verses ?? this.verses,
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentSurah: currentSurah ?? this.currentSurah,
      currentVerse: currentVerse ?? this.currentVerse,
    );
  }

  Verse? get currentVerseItem =>
      verses.isNotEmpty && currentIndex < verses.length
          ? verses[currentIndex]
          : null;

  bool get isLastVerse => currentIndex >= verses.length - 1;
}

/// Provider for feed state management.
final feedProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repository = ref.watch(quranRepositoryProvider);
  return FeedNotifier(repository);
});

/// Notifier class that manages the feed state.
class FeedNotifier extends StateNotifier<FeedState> {
  final QuranRepository _repository;

  FeedNotifier(this._repository) : super(const FeedState()) {
    _loadInitialVerses();
  }

  /// Loads the initial batch of verses for the feed.
  Future<void> _loadInitialVerses() async {
    state = state.copyWith(status: FeedStatus.loading);

    final result = await _repository.getSurahVerses(1);

    result.fold(
      onSuccess: (verses) {
        state = state.copyWith(
          verses: verses,
          status: FeedStatus.loaded,
          currentIndex: 0,
          currentSurah: 1,
          currentVerse: 1,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          status: FeedStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Moves to the next verse in the feed.
  Future<void> nextVerse() async {
    if (state.isLastVerse) {
      await _loadMoreVerses();
    }

    if (state.currentIndex < state.verses.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// Moves to the previous verse in the feed.
  void previousVerse() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Loads more verses when reaching the end of the current list.
  Future<void> _loadMoreVerses() async {
    final nextSurah = state.currentSurah + 1;
    if (nextSurah > 114) return;

    final result = await _repository.getSurahVerses(nextSurah);

    result.fold(
      onSuccess: (verses) {
        final updatedVerses = [...state.verses, ...verses];
        state = state.copyWith(
          verses: updatedVerses,
          currentSurah: nextSurah,
          currentVerse: 1,
          currentIndex: state.currentIndex + 1,
        );
      },
      onFailure: (_) {},
    );
  }

  /// Jumps to a specific verse.
  Future<void> jumpToVerse(int surahNumber, int verseNumber) async {
    state = state.copyWith(status: FeedStatus.loading);

    final surahResult = await _repository.getSurahVerses(surahNumber);

    surahResult.fold(
      onSuccess: (verses) {
        final index = verses.indexWhere((v) => v.number == verseNumber);
        final actualIndex = index >= 0 ? index : 0;

        state = state.copyWith(
          verses: verses,
          currentIndex: actualIndex,
          currentSurah: surahNumber,
          currentVerse: verses[actualIndex].number,
          status: FeedStatus.loaded,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          status: FeedStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Refreshes the feed from the beginning.
  Future<void> refresh() async {
    state = const FeedState();
    await _loadInitialVerses();
  }

  /// Toggles bookmark on current verse.
  void toggleBookmarkOnCurrent() {
    final current = state.currentVerseItem;
    if (current == null) return;

    final updated = current.copyWith(isBookmarked: !current.isBookmarked);
    final updatedVerses = List<Verse>.from(state.verses);
    updatedVerses[state.currentIndex] = updated;
    state = state.copyWith(verses: updatedVerses);
  }

  /// Toggles favorite on current verse.
  void toggleFavoriteOnCurrent() {
    final current = state.currentVerseItem;
    if (current == null) return;

    final updated = current.copyWith(isFavorite: !current.isFavorite);
    final updatedVerses = List<Verse>.from(state.verses);
    updatedVerses[state.currentIndex] = updated;
    state = state.copyWith(verses: updatedVerses);
  }
}
