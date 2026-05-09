/// lib/providers/nav_provider.dart
/// Riverpod state for the main bottom navigation tab index.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 0=Home, 1=Search, 2=Scan, 3=Borrowed, 4=Profile
final navIndexProvider = StateProvider<int>((ref) => 0);
