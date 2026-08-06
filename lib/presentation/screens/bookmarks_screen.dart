/// Bookmarks screen showing bookmarked verses.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/bookmark_provider.dart';

/// Screen displaying user's bookmarked verses.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Xatcho\'plar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: state.bookmarks.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    // Clear all bookmarks
                  },
                ),
              ]
            : null,
      ),
      body: state.bookmarks.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = state.bookmarks[index];
                return _BookmarkCard(
                  surahName: bookmark.surahName,
                  verseNumber: bookmark.verseNumber,
                  verseText: bookmark.verseText,
                  translation: bookmark.translation,
                  createdAt: bookmark.createdAt,
                  surahNumber: bookmark.surahNumber,
                  onDelete: () => ref
                      .read(bookmarkProvider.notifier)
                      .removeBookmark(bookmark.id),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Xatcho\'plar mavjud emas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Oyat kartasidagi xatcho\'p tugmasini bosing',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

/// Card widget for a bookmarked verse entry.
class _BookmarkCard extends StatelessWidget {
  final String surahName;
  final int verseNumber;
  final String verseText;
  final String translation;
  final DateTime createdAt;
  final int surahNumber;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
    required this.translation,
    required this.createdAt,
    required this.surahNumber,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('$surahNumber:$verseNumber'),
      onDismissed: (_) => onDelete(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.orange.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$surahName • $verseNumber',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        color: AppTheme.secondaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                verseText,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Uthmani',
                  fontSize: 18,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translation,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Bugun';
    if (diff.inDays == 1) return 'Kecha';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    return '${date.day}.${date.month}.${date.year}';
  }
}
