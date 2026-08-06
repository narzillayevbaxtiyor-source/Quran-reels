/// Tafsir overlay bottom sheet.
///
/// Displays detailed Quranic exegesis when the user long-presses
/// on a verse card.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/verse.dart';

/// A bottom sheet overlay showing tafsir (exegesis) for a verse.
class TafsirOverlay extends StatelessWidget {
  /// The verse to show tafsir for.
  final Verse verse;

  const TafsirOverlay({super.key, required this.verse});

  /// Shows the tafsir as a bottom sheet.
  static Future<void> show(BuildContext context, Verse verse) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TafsirOverlay(verse: verse),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tafsir',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            verse.reference,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic verse
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          verse.text,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 24,
                            height: 2.2,
                            fontFamily: 'Uthmani',
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Translation
                      Text(
                        'Tarjima (Uzbek)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          verse.translation,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tafsir content
                      Text(
                        'Tafsir',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTafsirContent(theme, isDark),
                      const SizedBox(height: 20),
                      // Surah info
                      _buildInfoRow('Sura', verse.surahNameUzbek,
                          Icons.mosque, theme),
                      _buildInfoRow(
                          'Oyat raqami',
                          '${verse.surahNumber}:${verse.number}',
                          Icons.format_list_numbered,
                          theme),
                      if (verse.juzNumber != null)
                        _buildInfoRow('Juz', '${verse.juzNumber}',
                            Icons.book, theme),
                      if (verse.pageNumber != null)
                        _buildInfoRow(
                            'Sahifa',
                            '${verse.pageNumber}',
                            Icons.menu_book,
                            theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTafsirContent(ThemeData theme, bool isDark) {
    // Placeholder tafsir text - in production, fetch from API
    const tafsirText =
        'Bu oyatda Alloh taolo insonlarni to\'g\'ri yo\'lga boshlash uchun '
        'o\'z kalomini nozil qilgan. Oyatning ma\'nosi chuqur va keng qamrovli '
        'bo\'lib, unda iymon, amal va axloq masalalari yoritilgan.\n\n'
        'Mufassirlar bu oyat haqida turli xil fikrlar bildirganlar. '
        'Eng muhim jihati shundaki, bu oyat musulmonlar uchun hidoyat manbai '
        'bo\'lib xizmat qiladi.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.2),
        ),
      ),
      child: Text(
        tafsirText,
        style: TextStyle(
          fontSize: 15,
          height: 1.8,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
