/// Favorites screen showing favorite verses.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/bookmark_provider.dart';

/// Screen displaying user's favorite verses.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saralanganlar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: state.favorites.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final fav = state.favorites[index];
                return _FavoriteCard(
                  surahName: fav.surahName,
                  verseNumber: fav.verseNumber,
                  verseText: fav.verseText,
                  translation: fav.translation,
                  surahNumber: fav.surahNumber,
                  onDelete: () =>
                      ref.read(bookmarkProvider.notifier).removeFavorite(fav.id),
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
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Saralanganlar mavjud emas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Oyat kartasiga ikki marta bosing',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

/// Card widget for a favorite verse entry.
class _FavoriteCard extends StatelessWidget {
  final String surahName;
  final int verseNumber;
  final String verseText;
  final String translation;
  final int surahNumber;
  final VoidCallback onDelete;

  const _FavoriteCard({
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
    required this.translation,
    required this.surahNumber,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('$surahNumber:$verseNumber'),
      onDismissed: (_) => onDelete(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
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
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                verseText,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Uthmani',
                  fontSize: 20,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translation,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
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
}
