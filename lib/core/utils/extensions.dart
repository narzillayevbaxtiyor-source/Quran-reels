/// Utility extensions used throughout the QuranReels application.
library;



/// Extension methods on [String] for Quran-specific text formatting.
extension StringExtensions on String {
  /// Returns `true` if the string contains Arabic characters.
  bool get isArabic {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(this);
  }

  /// Returns `true` if the string contains Cyrillic (Uzbek) characters.
  bool get isCyrillic {
    return RegExp(r'[\u0400-\u04FF]').hasMatch(this);
  }

  /// Capitalizes the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncates the string to [maxLength] and appends '...' if truncated.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Converts verse number format like "2:255" to a display format.
  String get formatVerseReference {
    final parts = split(':');
    if (parts.length == 2) {
      return '${parts[0]}-sura, ${parts[1]}-oyat';
    }
    return this;
  }
}

/// Extension methods on [int] for number formatting.
extension IntExtensions on int {
  /// Converts a number to a localized Uzbek string.
  String toUzbekNumber() {
    const uzbekDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return toString().split('').map((c) {
      final digit = int.tryParse(c);
      return digit != null ? uzbekDigits[digit] : c;
    }).join();
  }

  /// Formats the verse number with leading zero.
  String padVerse() => toString().padLeft(3, '0');
}

/// Extension methods on [DateTime].
extension DateTimeExtensions on DateTime {
  /// Formats as a relative time string in Uzbek.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365} yil oldin';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} oy oldin';
    if (diff.inDays > 0) return '${diff.inDays} kun oldin';
    if (diff.inHours > 0) return '${diff.inHours} soat oldin';
    if (diff.inMinutes > 0) return '${diff.inMinutes} daqiqa oldin';
    return 'Hozirgina';
  }
}

/// Extension on [BuildContext] for common operations.
extension BuildContextExtensions on Object {
  /// Returns the text direction for Arabic content.
  bool get isRTL {
    return false; // Default to LTR; override with locale check if needed
  }
}
