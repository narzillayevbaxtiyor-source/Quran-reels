/// Network service for fetching Quran data from the API.
///
/// Handles all API requests to alquran.cloud including:
/// - Listing all surahs
/// - Fetching individual verses with translations
/// - Searching by surah, verse, or translation
library;

import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/verse.dart';
import '../models/quran_models.dart';

/// Service class responsible for Quran API interactions.
class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // ─── Surah Endpoints ─────────────────────────────────────────────

  /// Fetches the list of all 114 surahs.
  ///
  /// Returns an [ApiResult] containing a list of [Surah] entities.
  Future<ApiResult<List<Surah>>> getAllSurahs() async {
    try {
      final response = await _dio.get('/surah');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final surahs = (data['surahs'] as List? ?? [])
            .map((json) => SurahModel.fromJson(json).toEntity())
            .toList();

        return ApiResult.success(surahs);
      }

      return ApiResult.failure(
        ServerFailure(
          message: 'Suralarni yuklashda xatolik yuz berdi',
          technicalMessage: 'Status code: ${response.statusCode}',
        ),
      );
    } on DioException catch (e) {
      return ApiResult.failure(
        NetworkFailure(
          message: 'Internet aloqasi yo\'q',
          technicalMessage: e.message,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(
          message: 'Kutilmagan xatolik yuz berdi',
          technicalMessage: e.toString(),
        ),
      );
    }
  }

  /// Fetches a single surah by its number (1-114).
  Future<ApiResult<Surah>> getSurah(int surahNumber) async {
    try {
      final response = await _dio.get('/surah/$surahNumber');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        // The API wraps surah info inside a surahs array sometimes
        final surahs = data['surahs'] as List?;
        final surahJson = surahs != null && surahs.isNotEmpty
            ? surahs.first as Map<String, dynamic>
            : data;

        final surah = SurahModel.fromJson(surahJson).toEntity();
        return ApiResult.success(surah);
      }

      return ApiResult.failure(
        ServerFailure(
          message: 'Surani yuklashda xatolik',
          technicalMessage: 'Status: ${response.statusCode}',
        ),
      );
    } on DioException catch (e) {
      return ApiResult.failure(
        NetworkFailure(
          message: 'Internet aloqasi yo\'q',
          technicalMessage: e.message,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(
          message: 'Kutilmagan xatolik',
          technicalMessage: e.toString(),
        ),
      );
    }
  }

  /// Fetches a verse with Uzbek translation.
  Future<ApiResult<VerseModel>> getVerseWithTranslation(
    int surahNumber,
    int verseNumber,
  ) async {
    try {
      final response = await _dio.get(
        '/ayah/$surahNumber:$verseNumber/uz.sodik',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;

        // Merge translation with verse data
        final translationText =
            data['text'] as String? ?? 'Tarjima mavjud emas';
        final translations = {'uz': translationText};

        final verseModel = VerseModel(
          number: data['number'] as int? ?? 0,
          text: data['text'] as String? ?? '',
          numberInSurah: data['numberInSurah'] as int? ?? verseNumber,
          juz: data['juz'] as int? ?? 0,
          page: data['page'] as int? ?? 0,
          surah: data['surah'] != null
              ? SurahModel.fromJson(data['surah'])
              : null,
          translations: translations,
        );

        return ApiResult.success(verseModel);
      }

      return ApiResult.failure(
        NotFoundFailure(
          message: 'Oyat topilmadi',
          technicalMessage: 'Status: ${response.statusCode}',
        ),
      );
    } on DioException catch (e) {
      return ApiResult.failure(
        NetworkFailure(
          message: 'Internet aloqasi yo\'q',
          technicalMessage: e.message,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(
          message: 'Kutilmagan xatolik',
          technicalMessage: e.toString(),
        ),
      );
    }
  }

  /// Fetches all verses of a surah with translations.
  Future<ApiResult<List<VerseModel>>> getSurahVerses(
    int surahNumber,
  ) async {
    try {
      final response = await _dio.get('/surah/$surahNumber/uz.sodik');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final ayahs = data['ayahs'] as List? ?? [];

        final verses = ayahs.map((ayah) {
          final ayahMap = ayah as Map<String, dynamic>;
          return VerseModel(
            number: ayahMap['number'] as int? ?? 0,
            text: ayahMap['text'] as String? ?? '',
            numberInSurah: ayahMap['numberInSurah'] as int? ?? 0,
            juz: ayahMap['juz'] as int? ?? 0,
            page: ayahMap['page'] as int? ?? 0,
            surah: data['surah'] != null
                ? SurahModel.fromJson(data['surah'])
                : null,
            translations: {'uz': ayahMap['text'] as String? ?? ''},
          );
        }).toList();

        return ApiResult.success(verses);
      }

      return ApiResult.failure(
        ServerFailure(
          message: 'Sura oyatlarni yuklashda xatolik',
        ),
      );
    } on DioException catch (e) {
      return ApiResult.failure(
        NetworkFailure(
          message: 'Internet aloqasi yo\'q',
          technicalMessage: e.message,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Kutilmagan xatolik'));
    }
  }

  // ─── Search Endpoints ────────────────────────────────────────────

  /// Searches the Quran by a text query.
  ///
  /// The API's search endpoint is limited; this performs a basic
  /// text search across surah names.
  Future<ApiResult<List<Surah>>> searchSurahs(String query) async {
    try {
      final allSurahsResult = await getAllSurahs();

      return allSurahsResult.fold(
        onSuccess: (surahs) {
          final lowerQuery = query.toLowerCase();
          final results = surahs.where((s) {
            return s.englishName.toLowerCase().contains(lowerQuery) ||
                s.uzbekName.toLowerCase().contains(lowerQuery) ||
                s.arabicName.contains(query);
          }).toList();
          return ApiResult.success(results);
        },
        onFailure: (failure) => ApiResult.failure(failure),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Qidirishda xatolik yuz berdi'),
      );
    }
  }

  /// Searches within surahs by verse content (client-side filtering).
  Future<ApiResult<List<Verse>>> searchVerses(
    String query, {
    int? surahNumber,
  }) async {
    try {
      final lowerQuery = query.toLowerCase();
      final List<Verse> results = [];

      if (surahNumber != null) {
        // Search within a specific surah
        final versesResult = await getSurahVerses(surahNumber);
        return versesResult.fold(
          onSuccess: (verses) {
            final matched = verses
                .where((v) =>
                    v.text.contains(query) ||
                    (v.translations['uz']?.toLowerCase() ?? '')
                        .contains(lowerQuery))
                .map((v) => v.toEntity())
                .toList();
            return ApiResult.success(matched);
          },
          onFailure: (failure) => ApiResult.failure(failure),
        );
      }

      // Search across multiple surahs
      for (int i = 1; i <= 10; i++) {
        final versesResult = await getSurahVerses(i);
        versesResult.fold(
          onSuccess: (verses) {
            results.addAll(
              verses
                  .where((v) =>
                      v.text.contains(query) ||
                      (v.translations['uz']?.toLowerCase() ?? '')
                          .contains(lowerQuery))
                  .map((v) => v.toEntity()),
            );
          },
          onFailure: (_) {},
        );
      }

      return ApiResult.success(results.take(50).toList());
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Qidirishda xatolik yuz berdi'),
      );
    }
  }

  // ─── Reciter Endpoints ───────────────────────────────────────────

  /// Fetches available reciters.
  Future<ApiResult<List<ReciterModel>>> getReciters() async {
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/edition?format=audio&language=ar&type=versebyverse',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        final reciters = data.map((json) {
          return ReciterModel(
            id: json['id'] as int? ?? 0,
            name: json['name'] as String? ?? '',
            nameArabic: json['name'] as String? ?? '',
            identifier: json['identifier'] as String? ?? '',
          );
        }).toList();
        return ApiResult.success(reciters);
      }

      return ApiResult.failure(
        ServerFailure(message: 'Qorilarni yuklashda xatolik'),
      );
    } on DioException catch (e) {
      return ApiResult.failure(
        NetworkFailure(
          message: 'Internet aloqasi yo\'q',
          technicalMessage: e.message,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Kutilmagan xatolik'));
    }
  }

  /// Builds audio URL for a specific verse and reciter.
  String buildAudioUrl(int surahNumber, int verseNumber,
      {String reciter = 'ar.alafasy'}) {
    final paddedSurah = surahNumber.toString().padLeft(3, '0');
    final paddedVerse = verseNumber.toString().padLeft(3, '0');
    return 'https://cdn.islamic.network/quran/audio/128/$reciter/$paddedSurah$paddedVerse.mp3';
  }
}
