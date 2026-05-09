import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'providers/store_provider.dart';
import 'providers/auth_provider.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise liblog-store (SharedPreferences) before providers start.
  await StorageService.init();

  runApp(const ProviderScope(child: LibLogApp()));
}

class LibLogApp extends ConsumerWidget {
  const LibLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    return MaterialApp(
      title: 'LibLog',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.light,
      darkTheme:  AppTheme.dark,
      themeMode:  isDark ? ThemeMode.dark : ThemeMode.light,
      home: _MobileContainer(
        child: isAuthenticated ? const MainLayout() : const LoginScreen(),
      ),
    );
  }
}

/// Enforces the 430px max-width mobile viewport from OVERVIEW.md §10.
class _MobileContainer extends StatelessWidget {
  final Widget child;
  const _MobileContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: child,
      ),
    );
  }
}
