/// Main entry point for the QuranReels application.
///
/// Initializes:
/// - Widgets binding
/// - Firebase
/// - Hive local storage
/// - System UI overlays
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'data/services/local_storage_service.dart';
// import 'firebase_options.dart';

/// Application entry point.
///
/// Initializes all required services before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style (transparent status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  // Uncomment when Firebase is configured:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize Hive for local storage
  await LocalStorageService.initialize();

  // Run the app with Riverpod scope
  runApp(
    const ProviderScope(
      child: QuranReelsApp(),
    ),
  );
}
