/// Firebase service for authentication, Firestore, and analytics.
///
/// Handles:
/// - Firebase Authentication (email, Google sign-in)
/// - Firestore CRUD for user data and sync
/// - Firebase Analytics event tracking
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/quran_models.dart';

/// Service class encapsulating all Firebase interactions.
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// The current authenticated user (null if not signed in).
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Authentication ──────────────────────────────────────────────

  /// Signs in with email and password.
  Future<ApiResult<UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return ApiResult.failure(
          AuthFailure(message: 'Kirishda xatolik yuz berdi'),
        );
      }

      await _analytics.logLogin(loginMethod: 'email');

      final userModel = await _getOrCreateUserDoc(credential.user!);
      return ApiResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return ApiResult.failure(
        AuthFailure(
          message: _getAuthErrorMessage(e.code),
          technicalMessage: e.message,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        AuthFailure(message: 'Kutilmagan xatolik yuz berdi'),
      );
    }
  }

  /// Creates a new account with email and password.
  Future<ApiResult<UserModel>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return ApiResult.failure(
          AuthFailure(message: 'Ro\'yxatdan o\'tishda xatolik'),
        );
      }

      await credential.user!.updateDisplayName(displayName);

      final userModel = await _createUserDoc(
        credential.user!,
        displayName: displayName,
      );

      await _analytics.logSignUp(signUpMethod: 'email');

      return ApiResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return ApiResult.failure(
        AuthFailure(
          message: _getAuthErrorMessage(e.code),
          technicalMessage: e.message,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        AuthFailure(message: 'Kutilmagan xatolik yuz berdi'),
      );
    }
  }

  /// Signs in with Google.
  Future<ApiResult<UserModel>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResult.failure(
          AuthFailure(message: 'Google orqali kirish bekor qilindi'),
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        return ApiResult.failure(
          AuthFailure(message: 'Google orqali kirishda xatolik'),
        );
      }

      await _analytics.logLogin(loginMethod: 'google');

      final userModel = await _getOrCreateUserDoc(userCredential.user!);
      return ApiResult.success(userModel);
    } catch (e) {
      return ApiResult.failure(
        AuthFailure(
          message: 'Google orqali kirishda xatolik yuz berdi',
          technicalMessage: e.toString(),
        ),
      );
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Firestore User Management ───────────────────────────────────

  /// Gets or creates a user document in Firestore.
  Future<UserModel> _getOrCreateUserDoc(User user) async {
    final docRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid);

    final doc = await docRef.get();

    if (doc.exists) {
      final userData = doc.data()!;
      final userModel = UserModel.fromJson({
        'uid': user.uid,
        ...userData,
      });

      // Update last login
      await docRef.update({'lastLoginAt': DateTime.now().toIso8601String()});

      return userModel;
    }

    return _createUserDoc(user);
  }

  /// Creates a new user document.
  Future<UserModel> _createUserDoc(User user, {String? displayName}) async {
    final now = DateTime.now();
    final userModel = UserModel(
      uid: user.uid,
      email: user.email,
      displayName: displayName ?? user.displayName ?? 'Foydalanuvchi',
      photoUrl: user.photoURL,
      createdAt: now,
      lastLoginAt: now,
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toJson());

    return userModel;
  }

  /// Updates user profile data.
  Future<ApiResult<bool>> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = currentUser;
      if (user == null) {
        return ApiResult.failure(
          AuthFailure(message: 'Foydalanuvchi tizimga kirmagan'),
        );
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(data);

      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Profil yangilashda xatolik'),
      );
    }
  }

  /// Syncs bookmarks to Firestore.
  Future<void> syncBookmarksToFirestore(List<BookmarkModel> bookmarks) async {
    final user = currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final userBookmarks = _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .collection(AppConstants.bookmarksCollection);

    for (final bookmark in bookmarks) {
      batch.set(userBookmarks.doc(bookmark.id), bookmark.toJson());
    }

    await batch.commit();
  }

  /// Fetches bookmarks from Firestore.
  Future<List<BookmarkModel>> getBookmarksFromFirestore() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection(AppConstants.bookmarksCollection)
          .get();

      return snapshot.docs.map((doc) {
        return BookmarkModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Analytics ───────────────────────────────────────────────────

  /// Logs an analytics event.
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Logs a verse view event.
  Future<void> logVerseView(int surah, int verse) async {
    await _analytics.logEvent(
      name: 'verse_view',
      parameters: {'surah': surah, 'verse': verse},
    );
  }

  /// Logs a verse play event.
  Future<void> logVersePlay(String verseId) async {
    await _analytics.logEvent(
      name: 'verse_play',
      parameters: {'verse_id': verseId},
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────

  /// Translates Firebase Auth error codes to user-friendly Uzbek messages.
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bunday foydalanuvchi topilmadi';
      case 'wrong-password':
        return 'Noto\'g\'ri parol';
      case 'email-already-in-use':
        return 'Bu email allaqachon ro\'yxatdan o\'tgan';
      case 'invalid-email':
        return 'Noto\'g\'ri email manzil';
      case 'weak-password':
        return 'Parol juda zaif (kamida 6 ta belgi)';
      case 'network-request-failed':
        return 'Internet aloqasi yo\'q';
      default:
        return 'Xatolik yuz berdi: $code';
    }
  }
}
