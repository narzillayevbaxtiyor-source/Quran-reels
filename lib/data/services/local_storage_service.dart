/// Local storage service using Hive for persistent data.
///
/// Manages bookmarks, favorites, settings, and search history
/// stored locally on the device.
library;

import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/quran_models.dart';

/// Service class for local data persistence using Hive.
class LocalStorageService {
  /// Opens all required Hive boxes. Must be called before any operations.
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters if needed
    // Hive.registerAdapter(BookmarkModelAdapter());

    await Future.wait([
      Hive.openBox<Map>(AppConstants.bookmarksBox),
      Hive.openBox<Map>(AppConstants.favoritesBox),
      Hive.openBox<Map>(AppConstants.settingsBox),
      Hive.openBox<Map>(AppConstants.recentsBox),
      Hive.openBox<String>(AppConstants.audioCacheBox),
    ]);
  }

  // ─── Bookmarks ───────────────────────────────────────────────────

  /// Returns the Hive box for bookmarks.
  Box<Map> get _bookmarksBox =>
      Hive.box<Map>(AppConstants.bookmarksBox);

  /// Saves a bookmark to local storage.
  Future<ApiResult<bool>> saveBookmark(BookmarkModel bookmark) async {
    try {
      await _bookmarksBox.put(bookmark.id, bookmark.toJson());
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure(
          message: 'Xatcho\'pni saqlashda xatolik',
          technicalMessage: e.toString(),
        ),
      );
    }
  }

  /// Removes a bookmark by ID.
  Future<ApiResult<bool>> removeBookmark(String id) async {
    try {
      await _bookmarksBox.delete(id);
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure(message: 'Xatcho\'pni o\'chirishda xatolik'),
      );
    }
  }

  /// Returns all saved bookmarks, sorted by newest first.
  ApiResult<List<BookmarkModel>> getAllBookmarks() {
    try {
      final bookmarks = _bookmarksBox.values.map((json) {
        return BookmarkModel.fromJson(Map<String, dynamic>.from(json));
      }).toList();

      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ApiResult.success(bookmarks);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure(message: 'Xatcho\'plarni yuklashda xatolik'),
      );
    }
  }

  /// Checks if a verse is bookmarked.
  bool isBookmarked(String verseId) {
    return _bookmarksBox.containsKey(verseId);
  }

  // ─── Favorites ───────────────────────────────────────────────────

  Box<Map> get _favoritesBox =>
      Hive.box<Map>(AppConstants.favoritesBox);

  /// Adds a verse to favorites.
  Future<ApiResult<bool>> addFavorite(BookmarkModel favorite) async {
    try {
      await _favoritesBox.put(favorite.id, favorite.toJson());
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure(message: 'Saralanganlarga qo\'shishda xatolik'),
      );
    }
  }

  /// Removes a verse from favorites.
  Future<ApiResult<bool>> removeFavorite(String id) async {
    try {
      await _favoritesBox.delete(id);
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure(message: 'Saralanganlardan o\'chirishda xatolik'),
      );
    }
  }

  /// Returns all favorites.
  ApiResult<List<BookmarkModel>> getAllFavorites() {
    try {
      final favorites = _favoritesBox.values.map((json) {
        return BookmarkModel.fromJson(Map<String, dynamic>.from(json));
      }).toList();
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ApiResult.success(favorites);
    } catch (e) {
      return ApiResult.failure(
        CacheFailure(message: 'Saralanganlarni yuklashda xatolik'),
      );
    }
  }

  /// Checks if a verse is in favorites.
  bool isFavorite(String verseId) {
    return _favoritesBox.containsKey(verseId);
  }

  // ─── Settings ────────────────────────────────────────────────────

  Box<Map> get _settingsBox =>
      Hive.box<Map>(AppConstants.settingsBox);

  /// Saves a setting value.
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, {'value': value});
  }

  /// Reads a setting value.
  T? getSetting<T>(String key) {
    final entry = _settingsBox.get(key);
    return entry?['value'] as T?;
  }

  // ─── Recent Searches ─────────────────────────────────────────────

  Box<Map> get _recentsBox => Hive.box<Map>(AppConstants.recentsBox);

  /// Adds to recent searches list.
  Future<void> addRecentSearch(String query) async {
    final key = 'recent_searches';
    final current = _recentsBox.get(key)?['searches'] as List? ?? [];
    final updated = [query, ...current.where((s) => s != query)].take(10).toList();
    await _recentsBox.put(key, {'searches': updated});
  }

  /// Gets recent searches.
  List<String> getRecentSearches() {
    final entry = _recentsBox.get('recent_searches');
    return (entry?['searches'] as List?)?.cast<String>() ?? [];
  }

  /// Clears recent searches.
  Future<void> clearRecentSearches() async {
    await _recentsBox.delete('recent_searches');
  }
}
