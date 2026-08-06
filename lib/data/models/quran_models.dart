/// Data models for the QuranReels application.
///
/// JSON serializable models that map to the Quran API responses.
library;

import '../../domain/entities/surah.dart';
import '../../domain/entities/verse.dart';

// ─── Surah Model ──────────────────────────────────────────────────

/// JSON-decoded model for a Surah from the alquran.cloud API.
class SurahModel {
  final int number;
  final String englishName;
  final String englishNameTranslation;
  final String name;
  final String uzbekName;
  final String revelationType;
  final int numberOfAyahs;
  final List<int> ayahs;

  const SurahModel({
    required this.number,
    required this.englishName,
    required this.englishNameTranslation,
    required this.name,
    required this.uzbekName,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
  });

  /// Parses a Surah from the API JSON response.
  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      englishName: json['englishName'] as String? ?? '',
      englishNameTranslation: json['englishNameTranslation'] as String? ?? '',
      name: json['name'] as String? ?? '',
      uzbekName: json['uzbekName'] as String? ?? json['englishName'] ?? '',
      revelationType: json['revelationType'] as String? ?? '',
      numberOfAyahs: json['numberOfAyahs'] as int? ?? 0,
      ayahs: json['ayahs'] != null
          ? (json['ayahs'] as List)
              .map((e) => (e['number'] as int?) ?? 0)
              .toList()
          : [],
    );
  }

  /// Converts to a domain [Surah] entity.
  Surah toEntity() {
    return Surah(
      number: number,
      englishName: englishName,
      englishNameTranslation: englishNameTranslation,
      arabicName: name,
      uzbekName: uzbekName,
      revelationType: revelationType,
      numberOfAyahs: numberOfAyahs,
      verses: ayahs,
    );
  }
}

// ─── Verse Model ──────────────────────────────────────────────────

/// JSON-decoded model for a single Quran verse from the API.
class VerseModel {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int page;
  final SurahModel? surah;
  final Map<String, String> translations;
  final Map<String, String> audios;

  const VerseModel({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.page,
    this.surah,
    this.translations = const {},
    this.audios = const {},
  });

  /// Parses a single verse from the API JSON response.
  factory VerseModel.fromJson(Map<String, dynamic> json) {
    final surahJson = json['surah'] as Map<String, dynamic>?;
    final surahModel =
        surahJson != null ? SurahModel.fromJson(surahJson) : null;

    // Handle translations - they may come in different formats
    final translations = <String, String>{};
    if (json['edition'] != null && json['edition']['name'] is String) {
      final editionName = json['edition']['name'] as String;
      final translationText = json['text'] as String? ?? '';
      translations[editionName] = translationText;
    }

    // Handle audio URLs
    final audios = <String, String>{};
    if (json['audio'] is String) {
      audios['primary'] = json['audio'] as String;
    } else if (json['audio'] is Map<String, dynamic>) {
      (json['audio'] as Map<String, dynamic>).forEach((key, value) {
        audios[key] = value.toString();
      });
    }

    return VerseModel(
      number: json['number'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      numberInSurah: json['numberInSurah'] as int? ?? 0,
      juz: json['juz'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      surah: surahModel,
      translations: translations,
      audios: audios,
    );
  }

  /// Converts to a domain [Verse] entity.
  Verse toEntity({
    String translationLang = 'uz',
    String audioReciter = 'ar.alafasy',
    bool isBookmarked = false,
    bool isFavorite = false,
  }) {
    final uzbekTranslation = translations[translationLang] ??
        translations.entries.firstOrNull?.value ??
        'Tarjima mavjud emas';

    final audioUrl = audios[audioReciter] ??
        audios['primary'] ??
        audios.entries.firstOrNull?.value;

    return Verse(
      number: numberInSurah,
      text: text,
      translation: uzbekTranslation,
      surahNumber: surah?.number ?? 1,
      surahNameEnglish: surah?.englishName ?? '',
      surahNameArabic: surah?.name ?? '',
      surahNameUzbek: surah?.uzbekName ?? '',
      juzNumber: juz,
      pageNumber: page,
      audioUrl: audioUrl,
      isBookmarked: isBookmarked,
      isFavorite: isFavorite,
    );
  }
}

// ─── Reciter Model ─────────────────────────────────────────────────

/// Data model for a Quran reciter.
class ReciterModel {
  final int id;
  final String name;
  final String nameArabic;
  final String identifier;
  final String? imageUrl;
  final String? description;

  const ReciterModel({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.identifier,
    this.imageUrl,
    this.description,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameArabic: json['nameArabic'] as String? ?? '',
      identifier: json['identifier'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'identifier': identifier,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}

// ─── Bookmark Model ────────────────────────────────────────────────

/// Data model for a bookmarked verse stored locally.
class BookmarkModel {
  final String id;
  final int surahNumber;
  final int verseNumber;
  final String surahName;
  final String verseText;
  final String translation;
  final DateTime createdAt;
  final String? note;

  const BookmarkModel({
    required this.id,
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
    required this.verseText,
    required this.translation,
    required this.createdAt,
    this.note,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String? ?? '',
      surahNumber: json['surahNumber'] as int? ?? 0,
      verseNumber: json['verseNumber'] as int? ?? 0,
      surahName: json['surahName'] as String? ?? '',
      verseText: json['verseText'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'surahName': surahName,
      'verseText': verseText,
      'translation': translation,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'note': note,
    };
  }

  Verse toEntity() {
    return Verse(
      number: verseNumber,
      text: verseText,
      translation: translation,
      surahNumber: surahNumber,
      surahNameEnglish: surahName,
      surahNameArabic: '',
      surahNameUzbek: surahName,
      isBookmarked: true,
    );
  }
}

// ─── User Model ────────────────────────────────────────────────────

/// Data model for authenticated user profile.
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? lastReciter;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> favoriteVerseIds;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.lastReciter,
    required this.createdAt,
    required this.lastLoginAt,
    this.favoriteVerseIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      lastReciter: json['lastReciter'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : DateTime.now(),
      favoriteVerseIds: json['favoriteVerseIds'] != null
          ? (json['favoriteVerseIds'] as List).cast<String>()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'lastReciter': lastReciter,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'favoriteVerseIds': favoriteVerseIds,
    };
  }
}
