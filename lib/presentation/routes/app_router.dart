/// Application router configuration using GoRouter.
///
/// Defines all routes for the QuranReels app including:
/// - Home (feed with bottom navigation)
/// - Search
/// - Favorites
/// - Bookmarks
/// - Profile
/// - Auth (sign in / sign up)
/// - Settings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';

/// Global key for the navigator used by GoRouter.
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider for the GoRouter instance.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Home shell route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Nested routes can be added here
        ],
      ),
      // Auth routes
      // GoRoute(
      //   path: '/auth',
      //   name: 'auth',
      //   builder: (context, state) => const AuthScreen(),
      // ),
      // Settings route
      // GoRoute(
      //   path: '/settings',
      //   name: 'settings',
      //   builder: (context, state) => const SettingsScreen(),
      // ),
    ],
    // Redirect logic for auth
    // redirect: (context, state) {
    //   final authState = ref.read(authProvider);
    //   final isAuthenticated = authState.isAuthenticated;
    //   final isAuthRoute = state.matchedLocation == '/auth';
    //
    //   if (!isAuthenticated && !isAuthRoute) {
    //     return '/auth';
    //   }
    //   if (isAuthenticated && isAuthRoute) {
    //     return '/';
    //   }
    //   return null;
    // },
  );
});
