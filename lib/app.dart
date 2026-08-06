/// Root App widget for QuranReels.
///
/// Configures MaterialApp with:
/// - GoRouter for navigation
/// - Dynamic light/dark theming
/// - Riverpod integration
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/routes/app_router.dart';

/// The root widget of the QuranReels application.
class QuranReelsApp extends ConsumerWidget {
  const QuranReelsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'QuranReels',
      debugShowCheckedModeBanner: false,
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.themeMode,
      // Router
      routerConfig: goRouter,
      // Locale
      locale: const Locale('uz'),
      supportedLocales: const [
        Locale('uz'),
        Locale('en'),
        Locale('ar'),
      ],
    );
  }
}
