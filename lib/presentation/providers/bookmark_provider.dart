/// Bookmarks and favorites state provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/quran_models.dart';
import '../../data/repositories/quran_repository.dart';
import '../../di/injection_container.dart';

/// Bookmarks state.
class BookmarkState {
  final List<BookmarkModel> bookmarks;
  final List<BookmarkModel> favorites;
  final bool isLoading;

  const BookmarkState({
    this.bookmarks = const [],
    this.favorites = const [],
    this.isLoading = false,
  });

  BookmarkState copyWith({
    List<BookmarkModel>? bookmarks,
    List<BookmarkModel>? favorites,
    bool? isLoading,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for bookmark state.
final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  final repository = ref.watch(quranRepositoryProvider);
  return BookmarkNotifier(repository);
});

/// Notifier that manages bookmarks and favorites.
class BookmarkNotifier extends StateNotifier<BookmarkState> {
  final QuranRepository _repository;

  BookmarkNotifier(this._repository) : super(const BookmarkState()) {
    loadAll();
  }

  /// Loads all bookmarks and favorites.
  void loadAll() {
    final bookmarksResult = _repository.getBookmarks();
    final favoritesResult = _repository.getFavorites();

    final bookmarks = bookmarksResult.fold(
      onSuccess: (data) => data,
      onFailure: (_) => <BookmarkModel>[],
    );

    final favorites = favoritesResult.fold(
      onSuccess: (data) => data,
      onFailure: (_) => <BookmarkModel>[],
    );

    state = state.copyWith(bookmarks: bookmarks, favorites: favorites);
  }

  /// Returns all bookmarks.
  List<BookmarkModel> get bookmarks => state.bookmarks;

  /// Returns all favorites.
  List<BookmarkModel> get favorites => state.favorites;

  /// Removes a bookmark.
  Future<void> removeBookmark(String id) async {
    await _repository.toggleBookmark;
    loadAll();
  }

  /// Removes a favorite.
  Future<void> removeFavorite(String id) async {
    await _repository.toggleFavorite;
    loadAll();
  }
}
