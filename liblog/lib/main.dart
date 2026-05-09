import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: LibLogApp()));
}

class LibLogApp extends ConsumerWidget {
  const LibLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'LibLog',
      debugShowCheckedModeBanner: false,
      // TODO: wire ThemeData from config/theme.dart
      home: const _MobileContainer(
        child: Scaffold(
          body: Center(child: Text('LibLog — scaffold complete')),
        ),
      ),
    );
  }
}

/// Enforces a max-width 430px mobile viewport (from OVERVIEW.md §10).
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
