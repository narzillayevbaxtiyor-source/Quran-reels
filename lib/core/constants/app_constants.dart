/// Application-wide constants used throughout the QuranReels app.
///
/// This class contains all static configuration values including
/// API endpoints, storage keys, and UI constants.
class AppConstants {
  AppConstants._();

  // ─── App Info ────────────────────────────────────────────────────
  static const String appName = 'QuranReels';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.quranreels.quran_reels';

  // ─── API Base URLs ───────────────────────────────────────────────
  static const String quranApiBaseUrl = 'https://api.alquran.cloud/v1';
  static const String quranAudioBaseUrl = 'https://cdn.islamic.network/quran/audio';

  // ─── Default Reciter ─────────────────────────────────────────────
  static const String defaultReciter = 'ar.alafasy';
  static const int defaultReciterId = 7; // Mishary Alafasy

  // ─── Audio Settings ──────────────────────────────────────────────
  static const double defaultPlaybackSpeed = 1.0;
  static const double minPlaybackSpeed = 0.5;
  static const double maxPlaybackSpeed = 2.0;

  // ─── Pagination ──────────────────────────────────────────────────
  static const int pageSize = 20;
  static const int maxSearchResults = 50;

  // ─── Animation Durations ─────────────────────────────────────────
  static const Duration pageAnimationDuration = Duration(milliseconds: 300);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 200);
  static const Duration bottomSheetDuration = Duration(milliseconds: 400);

  // ─── Hive Box Names ──────────────────────────────────────────────
  static const String bookmarksBox = 'bookmarks';
  static const String favoritesBox = 'favorites';
  static const String settingsBox = 'settings';
  static const String recentsBox = 'recents';
  static const String audioCacheBox = 'audioCache';

  // ─── SharedPreferences Keys ──────────────────────────────────────
  static const String prefsThemeMode = 'theme_mode';
  static const String prefsLastReciter = 'last_reciter';
  static const String prefsPlaybackSpeed = 'playback_speed';
  static const String prefsOnboardingComplete = 'onboarding_complete';
  static const String prefsLastPlayedVerse = 'last_played_verse';

  // ─── Firestore Collections ───────────────────────────────────────
  static const String usersCollection = 'users';
  static const String bookmarksCollection = 'bookmarks';
  static const String favoritesCollection = 'favorites';
  static const String playHistoryCollection = 'play_history';
  static const String recitersCollection = 'reciters';

  // ─── Surah Constants ─────────────────────────────────────────────
  static const int totalSurahs = 114;
  static const int totalVerses = 6236;

  // ─── UI Constants ────────────────────────────────────────────────

  /// Maximum lines for Arabic text on a verse card
  static const int maxArabicLines = 8;

  /// Maximum lines for translation text on a verse card
  static const int maxTranslationLines = 4;

  /// Bottom navigation bar height
  static const double bottomNavBarHeight = 64.0;

  /// Audio progress bar height
  static const double audioProgressBarHeight = 48.0;

  /// Default border radius for cards
  static const double defaultBorderRadius = 16.0;

  /// Horizontal padding for screens
  static const double screenHorizontalPadding = 16.0;
}
