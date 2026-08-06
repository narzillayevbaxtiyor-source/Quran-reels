/// Auth state provider for Firebase Authentication.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/quran_models.dart';
import '../../data/services/firebase_service.dart';

/// Authentication state.
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for auth state.
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Notifier for authentication management.
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseService _firebaseService = FirebaseService();

  AuthNotifier() : super(const AuthState()) {
    _checkAuthState();
  }

  /// Checks the initial auth state.
  void _checkAuthState() {
    final user = _firebaseService.currentUser;
    if (user != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: UserModel(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        ),
      );
    }
  }

  /// Signs in with email and password.
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result =
        await _firebaseService.signInWithEmail(email: email, password: password);

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Registers a new user.
  Future<bool> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _firebaseService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Signs in with Google.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _firebaseService.signInWithGoogle();

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseService.signOut();
    state = const AuthState();
  }

  /// Clears the error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
