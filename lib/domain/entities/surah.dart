/// Surah domain entity representing a chapter of the Quran.
library;

import 'package:equatable/equatable.dart';

/// Represents a Surah (chapter) of the Quran.
class Surah extends Equatable {
  /// Surah number (1-114).
  final int number;

  /// Surah name in English.
  final String englishName;

  /// English translation of the surah name.
  final String englishNameTranslation;

  /// Surah name in Arabic.
  final String arabicName;

  /// Surah name in Uzbek.
  final String uzbekName;

  /// Revelation type: "Meccan" or "Medinan".
  final String revelationType;

  /// Total number of verses in this surah.
  final int numberOfAyahs;

  /// List of verse numbers belonging to this surah.
  final List<int> verses;

  const Surah({
    required this.number,
    required this.englishName,
    required this.englishNameTranslation,
    required this.arabicName,
    required this.uzbekName,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.verses,
  });

  @override
  List<Object?> get props => [
        number,
        englishName,
        englishNameTranslation,
        arabicName,
        uzbekName,
        revelationType,
        numberOfAyahs,
        verses,
      ];

  /// Display name for the surah.
  String get displayName => '$number. $uzbekName';
}
