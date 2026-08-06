/// Home shell screen with bottom navigation bar.
///
/// Wraps the feed, search, favorites, bookmarks, and profile screens
/// inside a single scaffold with the bottom navigation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/bottom_nav_bar.dart';
import 'feed_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'bookmarks_screen.dart';
import 'profile_screen.dart';

/// Shell screen that manages bottom navigation.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  /// The list of screens managed by the bottom navigation.
  late final List<Widget> _screens = const [
    FeedScreen(),
    SearchScreen(),
    FavoritesScreen(),
    BookmarksScreen(),
    ProfileScreen(),
  ];

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: QuranBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
