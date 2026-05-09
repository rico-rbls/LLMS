/// storage_service.dart
/// SharedPreferences wrapper — persists only the fields listed in OVERVIEW.md §8.
///
/// Storage key: 'liblog-store'
///
/// Persisted fields:
///   user              → JSON string (full UserState)
///   onboardingStep    → int  (0-4)
///   onboardingData    → JSON string (registration form accumulator)
///   favorites         → JSON-encoded List<String> (resource IDs)
///
/// NOT persisted (always reset to defaults on app open):
///   currentScreen     → always resets to 'login'
///   isAuthenticated   → always resets to false
///   previousScreen    → transient navigation state
///   selectedBookId    → transient selection
///   searchQuery       → transient search text
///   searchCategory    → transient filter
///   unreadCount       → refreshed from API

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level storage key under which all fields are namespaced.
const _kStore = 'liblog-store';

/// Sub-keys stored inside SharedPreferences.
const _kUser           = '$_kStore:user';
const _kOnboardingStep = '$_kStore:onboardingStep';
const _kOnboardingData = '$_kStore:onboardingData';
const _kFavorites      = '$_kStore:favorites';

class StorageService {
  StorageService._();
  static StorageService? _instance;

  /// Singleton — call [StorageService.init()] once in [main] before [runApp].
  static StorageService get instance {
    assert(_instance != null, 'Call StorageService.init() before use.');
    return _instance!;
  }

  late final SharedPreferences _prefs;

  /// Initialise and return the singleton. Safe to call multiple times.
  static Future<StorageService> init() async {
    if (_instance != null) return _instance!;
    final svc = StorageService._();
    svc._prefs = await SharedPreferences.getInstance();
    _instance = svc;
    return svc;
  }

  // -------------------------------------------------------------------------
  // User
  // -------------------------------------------------------------------------

  /// Persist the full user map to storage.
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_kUser, jsonEncode(user));
  }

  /// Returns the persisted user map, or null if none exists.
  Map<String, dynamic>? loadUser() {
    final raw = _prefs.getString(_kUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearUser() => _prefs.remove(_kUser);

  // -------------------------------------------------------------------------
  // Onboarding
  // -------------------------------------------------------------------------

  Future<void> saveOnboardingStep(int step) =>
      _prefs.setInt(_kOnboardingStep, step);

  int loadOnboardingStep() => _prefs.getInt(_kOnboardingStep) ?? 0;

  Future<void> saveOnboardingData(Map<String, dynamic> data) =>
      _prefs.setString(_kOnboardingData, jsonEncode(data));

  Map<String, dynamic> loadOnboardingData() {
    final raw = _prefs.getString(_kOnboardingData);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearOnboarding() async {
    await _prefs.remove(_kOnboardingStep);
    await _prefs.remove(_kOnboardingData);
  }

  // -------------------------------------------------------------------------
  // Favorites
  // -------------------------------------------------------------------------

  Future<void> saveFavorites(List<String> ids) =>
      _prefs.setString(_kFavorites, jsonEncode(ids));

  List<String> loadFavorites() {
    final raw = _prefs.getString(_kFavorites);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<String>();
  }

  Future<void> clearFavorites() => _prefs.remove(_kFavorites);
  // -------------------------------------------------------------------------
  // Theme mode
  // -------------------------------------------------------------------------

  Future<void> saveThemeMode(bool isDark) =>
      _prefs.setBool('liblog-store:themeMode', isDark);

  bool loadThemeMode() =>
      _prefs.getBool('liblog-store:themeMode') ?? false;



  // -------------------------------------------------------------------------
  // Full clear (logout)
  // -------------------------------------------------------------------------

  /// Clears all persisted LibLog data. Called on logout.
  /// Does NOT touch currentScreen / isAuthenticated (never stored anyway).
  Future<void> clearAll() async {
    await Future.wait([
      clearUser(),
      clearOnboarding(),
      clearFavorites(),
    ]);
  }
}
