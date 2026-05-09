import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Exposes the already-initialised [StorageService] singleton to the
/// Riverpod graph. StorageService.init() MUST be called in main() before
/// ProviderScope is mounted.
///
/// Usage:
///   final storage = ref.read(storageServiceProvider);
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

// ─── Theme state ────────────────────────────────────────────────────────────

/// Persisted theme mode: 'light' | 'dark'. Defaults to light.
const _kThemeMode = 'liblog-store:themeMode';

class ThemeModeNotifier extends Notifier<bool> {
  // [state] = true means dark mode is active.
  @override
  bool build() {
    final prefs = ref.read(storageServiceProvider);
    return prefs.loadThemeMode();
  }

  void toggle() {
    state = !state;
    ref.read(storageServiceProvider).saveThemeMode(state);
  }

  void setDark(bool isDark) {
    state = isDark;
    ref.read(storageServiceProvider).saveThemeMode(isDark);
  }
}

/// [true] = Dark Purple Mode, [false] = Light Mode.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, bool>(
  ThemeModeNotifier.new,
);

// ─── Favorites state ─────────────────────────────────────────────────────────

class FavoritesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return ref.read(storageServiceProvider).loadFavorites();
  }

  void toggle(String resourceId) {
    final updated = List<String>.from(state);
    if (updated.contains(resourceId)) {
      updated.remove(resourceId);
    } else {
      updated.add(resourceId);
    }
    state = updated;
    ref.read(storageServiceProvider).saveFavorites(updated);
  }

  bool isFavorite(String resourceId) => state.contains(resourceId);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<String>>(
  FavoritesNotifier.new,
);
