/// Search state provider for Quran search functionality.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/quran_repository.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/verse.dart';
import '../../di/injection_container.dart';

/// Search state.
class SearchState {
  final String query;
  final bool isSearching;
  final List<Surah> surahResults;
  final List<Verse> verseResults;
  final List<String> recentSearches;
  final String? errorMessage;

  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.surahResults = const [],
    this.verseResults = const [],
    this.recentSearches = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    String? query,
    bool? isSearching,
    List<Surah>? surahResults,
    List<Verse>? verseResults,
    List<String>? recentSearches,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      surahResults: surahResults ?? this.surahResults,
      verseResults: verseResults ?? this.verseResults,
      recentSearches: recentSearches ?? this.recentSearches,
      errorMessage: errorMessage,
    );
  }

  bool get hasResults =>
      surahResults.isNotEmpty || verseResults.isNotEmpty;
}

/// Provider for search state.
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(quranRepositoryProvider);
  return SearchNotifier(repository);
});

/// Notifier that manages search state and operations.
class SearchNotifier extends StateNotifier<SearchState> {
  final QuranRepository _repository;

  SearchNotifier(this._repository)
      : super(
          SearchState(recentSearches: _repository.getRecentSearches()),
        );

  /// Sets the search query.
  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Performs search by surah name or verse content.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(surahResults: [], verseResults: []);
      return;
    }

    state = state.copyWith(isSearching: true, query: query);

    // Run surah and verse search in parallel
    final surahFuture = _repository.searchSurahs(query);
    final verseFuture = _repository.searchVerses(query);

    final surahResult = await surahFuture;
    final verseResult = await verseFuture;

    final surahs = surahResult.fold(
      onSuccess: (data) => data,
      onFailure: (_) => <Surah>[],
    );

    final verses = verseResult.fold(
      onSuccess: (data) => data,
      onFailure: (_) => <Verse>[],
    );

    state = state.copyWith(
      isSearching: false,
      surahResults: surahs,
      verseResults: verses,
      recentSearches: _repository.getRecentSearches(),
    );
  }

  /// Clears search results.
  void clearResults() {
    state = state.copyWith(
      query: '',
      surahResults: [],
      verseResults: [],
    );
  }

  /// Clears recent searches.
  Future<void> clearRecent() async {
    await _repository.clearRecentSearches();
    state = state.copyWith(
        recentSearches: _repository.getRecentSearches());
  }
}
