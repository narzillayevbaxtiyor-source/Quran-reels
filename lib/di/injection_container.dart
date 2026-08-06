/// Dependency injection container using Riverpod providers.
///
/// All service and repository instances are registered as providers
/// so they can be injected into screens and widgets via ref.watch/ref.read.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../data/repositories/quran_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/audio_service.dart';
import '../data/services/firebase_service.dart';
import '../data/services/local_storage_service.dart';

// ─── HTTP Client ──────────────────────────────────────────────────

/// Provider for the Dio HTTP client.
final dioProvider = Provider<Dio>((ref) {
  return DioClient.instance;
});

// ─── Services ─────────────────────────────────────────────────────

/// Provider for the Quran API service.
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio: dio);
});

/// Provider for the local storage service.
///
/// Note: LocalStorageService.initialize() must be called before use.
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Provider for the audio service.
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

/// Provider for the Firebase service.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// ─── Repositories ─────────────────────────────────────────────────

/// Provider for the Quran repository.
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return QuranRepository(
    apiService: apiService,
    localStorage: localStorage,
  );
});
