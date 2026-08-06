/// Environment configuration for different build environments.
///
/// Supports development, staging, and production environments
/// with appropriate settings for each.
library;

/// Available application environments.
enum AppEnvironment { development, staging, production }

/// Configuration class holding environment-specific values.
class EnvironmentConfig {
  /// The current environment.
  final AppEnvironment environment;

  /// Base API URL for Quran data.
  final String quranApiBaseUrl;

  /// Audio CDN base URL.
  final String audioCdnBaseUrl;

  /// Whether to enable debug logging.
  final bool enableLogging;

  /// Whether to enable analytics.
  final bool enableAnalytics;

  /// Whether to enable crash reporting.
  final bool enableCrashReporting;

  /// Firebase project ID.
  final String firebaseProjectId;

  /// Whether to use Firebase emulators.
  final bool useFirebaseEmulators;

  /// Firebase emulator host (when useFirebaseEmulators is true).
  final String? firebaseEmulatorHost;

  const EnvironmentConfig({
    required this.environment,
    required this.quranApiBaseUrl,
    required this.audioCdnBaseUrl,
    this.enableLogging = false,
    this.enableAnalytics = false,
    this.enableCrashReporting = false,
    this.firebaseProjectId = '',
    this.useFirebaseEmulators = false,
    this.firebaseEmulatorHost,
  });

  /// Returns `true` if this is a development environment.
  bool get isDevelopment => environment == AppEnvironment.development;

  /// Returns `true` if this is a production environment.
  bool get isProduction => environment == AppEnvironment.production;

  /// Development configuration.
  static const EnvironmentConfig development = EnvironmentConfig(
    environment: AppEnvironment.development,
    quranApiBaseUrl: 'https://api.alquran.cloud/v1',
    audioCdnBaseUrl: 'https://cdn.islamic.network/quran/audio',
    enableLogging: true,
    enableAnalytics: false,
    enableCrashReporting: false,
    firebaseProjectId: 'quran-reels-dev',
    useFirebaseEmulators: true,
    firebaseEmulatorHost: 'localhost',
  );

  /// Staging configuration.
  static const EnvironmentConfig staging = EnvironmentConfig(
    environment: AppEnvironment.staging,
    quranApiBaseUrl: 'https://api.alquran.cloud/v1',
    audioCdnBaseUrl: 'https://cdn.islamic.network/quran/audio',
    enableLogging: true,
    enableAnalytics: true,
    enableCrashReporting: true,
    firebaseProjectId: 'quran-reels-staging',
  );

  /// Production configuration.
  static const EnvironmentConfig production = EnvironmentConfig(
    environment: AppEnvironment.production,
    quranApiBaseUrl: 'https://api.alquran.cloud/v1',
    audioCdnBaseUrl: 'https://cdn.islamic.network/quran/audio',
    enableLogging: false,
    enableAnalytics: true,
    enableCrashReporting: true,
    firebaseProjectId: 'quran-reels-prod',
  );

  /// Returns the configuration for the current build environment.
  ///
  /// In production, this reads from compiled constants.
  /// In development, it defaults to the development config.
  static EnvironmentConfig get current {
    // In a real app, this would be determined by build flavor
    // For now, default to development
    // const isProduction = bool.fromEnvironment('dart.vm.product');
    // return isProduction ? production : development;
    return development;
  }
}
