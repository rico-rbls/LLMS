/// lib/providers/auth_provider.dart
/// Transient auth state — never persisted to shared_preferences.
/// isAuthenticated and currentScreen always reset to false/'login' on app open.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../utils/auth.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) => AuthState(
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Always start unauthenticated — security rule from OVERVIEW.md §8.
    return const AuthState();
  }

  /// Attempts login against the backend. Hashes password client-side first.
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final hashed = hashPassword(password);
      // TODO: replace with real API call via AuthService
      // Simulate demo account check
      if (email == 'juan@university.edu' && hashed == hashPassword('password123')) {
        final demoUser = User(
          id: 'demo-001',
          email: email,
          fullName: 'Juan Dela Cruz',
          universityId: '2021-00001',
          role: 'student',
          avatarInitials: 'JD',
          isOnboarded: true,
        );
        // Persist user object but NOT isAuthenticated
        await StorageService.instance.saveUser(demoUser.toJson());
        state = state.copyWith(isAuthenticated: true, user: demoUser, isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Invalid email or password.');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Registers a new user. Hashes password before submission.
  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: connect to real AuthService.register()
      await StorageService.instance.clearOnboarding();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void logout() {
    StorageService.instance.clearAll();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
