/// Verse domain entity representing a single Quranic verse.
///
/// This is the pure domain entity with no framework dependencies.
library;

import 'package:equatable/equatable.dart';

/// Represents a single verse (ayat) from the Quran.
class Verse extends Equatable {
  /// Verse number within the surah (1-based).
  final int number;

  /// Arabic text of the verse in Uthmani script.
  final String text;

  /// Translation of the verse in Uzbek.
  final String translation;

  /// Transliteration of the Arabic text.
  final String? transliteration;

  /// Surah number (1-114).
  final int surahNumber;

  /// Surah name in English.
  final String surahNameEnglish;

  /// Surah name in Arabic.
  final String surahNameArabic;

  /// Surah name in Uzbek.
  final String surahNameUzbek;

  /// Page number in the Mushaf (optional).
  final int? pageNumber;

  /// Juz number (1-30) (optional).
  final int? juzNumber;

  /// Audio URL for the recitation of this verse.
  final String? audioUrl;

  /// Whether this verse is bookmarked by the user.
  final bool isBookmarked;

  /// Whether this verse is marked as a favorite.
  final bool isFavorite;

  const Verse({
    required this.number,
    required this.text,
    required this.translation,
    this.transliteration,
    required this.surahNumber,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    required this.surahNameUzbek,
    this.pageNumber,
    this.juzNumber,
    this.audioUrl,
    this.isBookmarked = false,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [
        number,
        text,
        translation,
        transliteration,
        surahNumber,
        surahNameEnglish,
        surahNameArabic,
        surahNameUzbek,
        pageNumber,
        juzNumber,
        audioUrl,
        isBookmarked,
        isFavorite,
      ];

  /// Creates a copy with the given fields replaced.
  Verse copyWith({
    int? number,
    String? text,
    String? translation,
    String? transliteration,
    int? surahNumber,
    String? surahNameEnglish,
    String? surahNameArabic,
    String? surahNameUzbek,
    int? pageNumber,
    int? juzNumber,
    String? audioUrl,
    bool? isBookmarked,
    bool? isFavorite,
  }) {
    return Verse(
      number: number ?? this.number,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      transliteration: transliteration ?? this.transliteration,
      surahNumber: surahNumber ?? this.surahNumber,
      surahNameEnglish: surahNameEnglish ?? this.surahNameEnglish,
      surahNameArabic: surahNameArabic ?? this.surahNameArabic,
      surahNameUzbek: surahNameUzbek ?? this.surahNameUzbek,
      pageNumber: pageNumber ?? this.pageNumber,
      juzNumber: juzNumber ?? this.juzNumber,
      audioUrl: audioUrl ?? this.audioUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Unique identifier for this verse.
  String get id => '$surahNumber:$number';

  /// Reference string like "Al-Fatiha 1:1"
  String get reference => '$surahNameUzbek $surahNumber:$number';
}
