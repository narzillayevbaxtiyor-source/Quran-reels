/// Repository that coordinates Quran data between API and local storage.
///
/// Implements the repository pattern from Clean Architecture,
/// deciding when to fetch from the network vs. local cache.
library;

import '../../core/errors/failures.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/verse.dart';
import '../models/quran_models.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

/// Repository for Quran data access.
class QuranRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  QuranRepository({
    required ApiService apiService,
    required LocalStorageService localStorage,
  })  : _apiService = apiService,
        _localStorage = localStorage;

  // ─── Surahs ──────────────────────────────────────────────────────

  /// Fetches all 114 surahs from the API.
  Future<ApiResult<List<Surah>>> getAllSurahs() async {
    return _apiService.getAllSurahs();
  }

  /// Fetches a specific surah by number.
  Future<ApiResult<Surah>> getSurah(int surahNumber) async {
    return _apiService.getSurah(surahNumber);
  }

  // ─── Verses ──────────────────────────────────────────────────────

  /// Fetches a complete verse with translation and audio URL.
  Future<ApiResult<Verse>> getVerse(
    int surahNumber,
    int verseNumber,
  ) async {
    final result =
        await _apiService.getVerseWithTranslation(surahNumber, verseNumber);

    return result.fold(
      onSuccess: (verseModel) {
        final verse = verseModel.toEntity(
          isBookmarked: _localStorage.isBookmarked(
            '$surahNumber:$verseNumber',
          ),
          isFavorite: _localStorage.isFavorite(
            '$surahNumber:$verseNumber',
          ),
        );
        return ApiResult.success(verse);
      },
      onFailure: (failure) => ApiResult.failure(failure),
    );
  }

  /// Fetches all verses for a given surah.
  Future<ApiResult<List<Verse>>> getSurahVerses(
    int surahNumber,
  ) async {
    final result = await _apiService.getSurahVerses(surahNumber);

    return result.fold(
      onSuccess: (verseModels) {
        final verses = verseModels.map((model) {
          final verse = model.toEntity(
            isBookmarked: _localStorage.isBookmarked(
              '$surahNumber:${model.numberInSurah}',
            ),
            isFavorite: _localStorage.isFavorite(
              '$surahNumber:${model.numberInSurah}',
            ),
          );
          return verse;
        }).toList();
        return ApiResult.success(verses);
      },
      onFailure: (failure) => ApiResult.failure(failure),
    );
  }

  /// Gets the next verse in sequence.
  Future<ApiResult<Verse>> getNextVerse(
    int currentSurah,
    int currentVerse,
  ) async {
    try {
      // Try next verse in same surah
      final nextVerse = currentVerse + 1;
      final nextResult =
          await _apiService.getVerseWithTranslation(currentSurah, nextVerse);

      return nextResult.fold(
        onSuccess: (model) {
          return ApiResult.success(model.toEntity(
            isBookmarked: _localStorage.isBookmarked(
              '$currentSurah:$nextVerse',
            ),
            isFavorite: _localStorage.isFavorite(
              '$currentSurah:$nextVerse',
            ),
          ));
        },
        onFailure: (failure) {
          // If next verse fails (end of surah), try first verse of next surah
          if (failure is NotFoundFailure && currentSurah < 114) {
            // Will be handled by the caller
            return ApiResult.failure(failure);
          }
          return ApiResult.failure(failure);
        },
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Keyingi oyatni yuklashda xatolik'),
      );
    }
  }

  /// Gets the previous verse in sequence.
  Future<ApiResult<Verse>> getPreviousVerse(
    int currentSurah,
    int currentVerse,
  ) async {
    try {
      final prevVerse = currentVerse - 1;

      if (prevVerse < 1) {
        // Go to last verse of previous surah
        if (currentSurah > 1) {
          final prevSurahResult = await getSurah(currentSurah - 1);
          return prevSurahResult.fold(
            onSuccess: (prevSurah) {
              return getVerse(currentSurah - 1, prevSurah.numberOfAyahs);
            },
            onFailure: (failure) => ApiResult.failure(failure),
          );
        }
        return ApiResult.failure(
          NotFoundFailure(message: 'Bu birinchi oyat'),
        );
      }

      final result =
          await _apiService.getVerseWithTranslation(currentSurah, prevVerse);

      return result.fold(
        onSuccess: (model) {
          return ApiResult.success(model.toEntity(
            isBookmarked: _localStorage.isBookmarked(
              '$currentSurah:$prevVerse',
            ),
            isFavorite: _localStorage.isFavorite(
              '$currentSurah:$prevVerse',
            ),
          ));
        },
        onFailure: (failure) => ApiResult.failure(failure),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Oldingi oyatni yuklashda xatolik'),
      );
    }
  }

  // ─── Search ──────────────────────────────────────────────────────

  /// Searches surahs by name.
  Future<ApiResult<List<Surah>>> searchSurahs(String query) async {
    await _localStorage.addRecentSearch(query);
    return _apiService.searchSurahs(query);
  }

  /// Searches verses by content.
  Future<ApiResult<List<Verse>>> searchVerses(
    String query, {
    int? surahNumber,
  }) async {
    await _localStorage.addRecentSearch(query);
    return _apiService.searchVerses(query, surahNumber: surahNumber);
  }

  // ─── Bookmarks ───────────────────────────────────────────────────

  /// Toggles a verse bookmark.
  Future<ApiResult<bool>> toggleBookmark(Verse verse) async {
    final verseId = verse.id;

    if (_localStorage.isBookmarked(verseId)) {
      return _localStorage.removeBookmark(verseId);
    }

    final bookmark = BookmarkModel(
      id: verseId,
      surahNumber: verse.surahNumber,
      verseNumber: verse.number,
      surahName: verse.surahNameUzbek,
      verseText: verse.text,
      translation: verse.translation,
      createdAt: DateTime.now(),
    );

    return _localStorage.saveBookmark(bookmark);
  }

  /// Toggles a verse favorite.
  Future<ApiResult<bool>> toggleFavorite(Verse verse) async {
    final verseId = verse.id;

    if (_localStorage.isFavorite(verseId)) {
      return _localStorage.removeFavorite(verseId);
    }

    final favorite = BookmarkModel(
      id: verseId,
      surahNumber: verse.surahNumber,
      verseNumber: verse.number,
      surahName: verse.surahNameUzbek,
      verseText: verse.text,
      translation: verse.translation,
      createdAt: DateTime.now(),
    );

    return _localStorage.addFavorite(favorite);
  }

  /// Checks if a verse is bookmarked.
  bool isBookmarked(String verseId) => _localStorage.isBookmarked(verseId);

  /// Checks if a verse is favorited.
  bool isFavorite(String verseId) => _localStorage.isFavorite(verseId);

  /// Gets all bookmarks.
  ApiResult<List<BookmarkModel>> getBookmarks() =>
      _localStorage.getAllBookmarks();

  /// Gets all favorites.
  ApiResult<List<BookmarkModel>> getFavorites() =>
      _localStorage.getAllFavorites();

  // ─── Reciters ────────────────────────────────────────────────────

  /// Gets the list of available reciters.
  Future<ApiResult<List<ReciterModel>>> getReciters() async {
    return _apiService.getReciters();
  }

  /// Gets resent searches.
  List<String> getRecentSearches() => _localStorage.getRecentSearches();

  /// Clears recent searches.
  Future<void> clearRecentSearches() async {
    await _localStorage.clearRecentSearches();
  }
}
