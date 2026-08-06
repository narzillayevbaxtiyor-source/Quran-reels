/// Search screen for finding surahs, verses, and translations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/verse.dart';
import '../providers/feed_provider.dart';
import '../providers/search_provider.dart';

/// Search screen for Quran content.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Qidirish',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search input
          _buildSearchInput(theme, searchState.query),
          // Results or recent searches
          Expanded(
            child: searchState.isSearching
                ? const Center(child: CircularProgressIndicator())
                : searchState.query.isNotEmpty
                    ? _buildSearchResults(searchState, theme)
                    : _buildRecentSearches(searchState, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(ThemeData theme, String query) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Sura yoki oyat izlash...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clearResults();
                  },
                )
              : null,
          filled: true,
          fillColor: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            ref.read(searchProvider.notifier).search(value.trim());
          }
        },
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState, ThemeData theme) {
    if (!searchState.hasResults && searchState.query.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Natijalar topilmadi',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Surah results
        if (searchState.surahResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Suralar',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...searchState.surahResults.map(
            (surah) => _SurahResultTile(
              surah: surah,
              onTap: () => _navigateToSurah(surah),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Verse results
        if (searchState.verseResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Oyatlar',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...searchState.verseResults.map(
            (verse) => _VerseResultTile(verse: verse, onTap: () {}),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentSearches(SearchState searchState, ThemeData theme) {
    if (searchState.recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Yaqinda qidirilganlar mavjud emas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Yaqinda qidirilganlar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(searchProvider.notifier).clearRecent();
              },
              child: const Text('Tozalash'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...searchState.recentSearches.map(
          (query) => ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(query),
            onTap: () {
              _searchController.text = query;
              ref.read(searchProvider.notifier).search(query);
            },
          ),
        ),
      ],
    );
  }

  void _navigateToSurah(Surah surah) {
    ref.read(feedProvider.notifier).jumpToVerse(surah.number, 1);
  }
}

/// Tile widget for displaying surah search results.
class _SurahResultTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _SurahResultTile({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            '${surah.number}',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          surah.uzbekName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          surah.englishName,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              surah.arabicName,
              style: const TextStyle(
                fontFamily: 'Uthmani',
                fontSize: 18,
              ),
            ),
            Text(
              '${surah.numberOfAyahs} oyat',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Tile widget for displaying verse search results.
class _VerseResultTile extends StatelessWidget {
  final Verse verse;
  final VoidCallback onTap;

  const _VerseResultTile({
    required this.verse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              verse.surahNameUzbek,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              verse.text,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Uthmani', fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              verse.translation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
