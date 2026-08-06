/// API Constants and endpoint definitions for QuranReels.
///
/// Centralizes all API URLs, configuration values, and
/// environment-specific settings.
class ApiConstants {
  ApiConstants._();

  // ─── Base URLs ───────────────────────────────────────────────────

  /// AlQuran Cloud API v1
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  /// Quran audio CDN
  static const String audioCdn = 'https://cdn.islamic.network/quran/audio';

  /// Quran edition endpoints
  static const String editionsUrl = '$baseUrl/edition';

  // ─── Endpoints ───────────────────────────────────────────────────

  /// Get all surahs
  static String get surahs => '$baseUrl/surah';

  /// Get specific surah
  static String surah(int number) => '$baseUrl/surah/$number';

  /// Get ayah with edition (translation)
  static String ayahWithEdition(int surah, int verse, String edition) =>
      '$baseUrl/ayah/$surah:$verse/$edition';

  /// Get surah with translation
  static String surahWithTranslation(int surah, String edition) =>
      '$baseUrl/surah/$surah/$edition';

  /// Search endpoint
  static String search(String query, String language) =>
      '$baseUrl/search/$query/all/$language';

  // ─── Audio URLs ──────────────────────────────────────────────────

  /// Build verse audio URL
  static String verseAudio(int surah, int verse, String reciter) {
    final surahPadded = surah.toString().padLeft(3, '0');
    final versePadded = verse.toString().padLeft(3, '0');
    return '$audioCdn/128/$reciter/$surahPadded$versePadded.mp3';
  }

  /// Build full surah audio URL
  static String fullSurahAudio(int surah, String reciter) {
    final surahPadded = surah.toString().padLeft(3, '0');
    return '$audioCdn/128/$reciter/$surahPadded.mp3';
  }

  // ─── Translation Editions ────────────────────────────────────────

  /// Uzbek translation by Alouddin Mansur
  static const String uzbekTranslationEdition = 'uz.sodik';

  /// English translation by Sahih International
  static const String englishTranslationEdition = 'en.sahih';

  /// Russian translation
  static const String russianTranslationEdition = 'ru.kuliev';

  // ─── Audio Editions (Reciters) ───────────────────────────────────

  static const Map<String, String> reciterNames = {
    'ar.alafasy': 'Mishary Rashid Alafasy',
    'ar.husary': 'Mahmoud Khalil Al-Husary',
    'ar.abdulbasit': 'Abdul Basit Abdus Samad',
    'ar.sudais': 'Abdul Rahman Al-Sudais',
    'ar.ahmedajamy': 'Ahmed Al-Ajamy',
    'ar.minshawi': 'Mohamed Siddiq Al-Minshawi',
    'ar.mahermuaiqly': 'Maher Al-Muaiqly',
  };

  // ─── Timeouts ────────────────────────────────────────────────────

  /// API request timeout
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Audio stream timeout
  static const Duration audioStreamTimeout = Duration(seconds: 30);

  /// Long audio operation timeout
  static const Duration longOperationTimeout = Duration(minutes: 5);

  // ─── Pagination ──────────────────────────────────────────────────

  /// Default page size for list endpoints
  static const int defaultPageSize = 20;

  /// Maximum search results
  static const int maxSearchResults = 50;

  /// Maximum recent searches stored
  static const int maxRecentSearches = 10;

  // ─── Feature Flags ───────────────────────────────────────────────

  /// Enable Firebase sync
  static const bool enableFirebaseSync = true;

  /// Enable analytics
  static const bool enableAnalytics = true;

  /// Enable crash reporting
  static const bool enableCrashReporting = true;

  /// Enable audio caching
  static const bool enableAudioCache = true;
}
