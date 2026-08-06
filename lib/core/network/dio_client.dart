/// Dio HTTP client configuration with interceptors.
///
/// Provides a pre-configured Dio instance with logging, error handling,
/// and retry logic for communicating with the Quran API.
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

/// Creates and returns a pre-configured [Dio] HTTP client.
///
/// Includes:
/// - Base URL pointing to the Quran API
/// - Logging interceptors
/// - Timeout configuration
/// - Error interceptor for consistent error handling
class DioClient {
  DioClient._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: false,
      printEmojis: true,
    ),
  );

  /// Singleton Dio instance.
  static Dio? _instance;

  /// Returns the singleton Dio instance, creating it if necessary.
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  /// Creates a fresh Dio instance (useful for testing).
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.quranApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => _logger.d(obj),
      ),
    );

    // Add error interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _logger.e(
            'Dio Error',
            error: error.message,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Creates a separate Dio instance for audio streaming
  /// with a longer timeout.
  static Dio createAudioDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConstants.quranAudioBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }
}
