/// lib/screens/search_screen.dart
/// Catalog browser: 300ms debounced search, category pills, shimmer skeletons, recently viewed.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../config/colors.dart';
import '../providers/resource_provider.dart';
import '../widgets/search_result_card.dart';
import 'resource_detail_screen.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final _searchQueryProvider   = StateProvider<String>((ref) => '');
final _searchCategoryProvider = StateProvider<String>((ref) => 'all');
final _isSearchingProvider   = StateProvider<bool>((ref) => false);

// ── Screen ───────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode  = FocusNode();
  Timer? _debounce;

  static const _categories = ['all', 'book', 'research', 'magazine'];
  static const _categoryLabels = {
    'all': 'All', 'book': 'Books',
    'research': 'Research', 'magazine': 'Magazines',
  };
  
  static const _categoryIcons = {
    'all': Icons.search_rounded,
    'book': Icons.menu_book_rounded,
    'research': Icons.article_rounded,
    'magazine': Icons.auto_stories_rounded,
  };

  static const _popularTags = [
    'Algorithms', 'Deep Learning', 'Database',
    'Nursing', 'Psychology', 'Clean Code',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    ref.read(_isSearchingProvider.notifier).state = true;
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      ref.read(_searchQueryProvider.notifier).state = value;
      ref.read(_isSearchingProvider.notifier).state = false;
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _onSearchChanged('');
    _focusNode.unfocus();
  }

  void _applyTag(String tag) {
    _searchCtrl.text = tag;
    _onSearchChanged(tag);
  }

  @override
  Widget build(BuildContext context) {
    final query       = ref.watch(_searchQueryProvider);
    final category    = ref.watch(_searchCategoryProvider);
    final isSearching = ref.watch(_isSearchingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2FA), // Light theme background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search Catalog', style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // Search input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search books, research, magazines...',
                        hintStyle: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mutedForeground),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColors.mutedForeground),
                              onPressed: _clearSearch,
                            )
                          : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Popular Tags
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.mutedForeground),
                      const SizedBox(width: 6),
                      const Text('POPULAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.mutedForeground)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _popularTags.map((tag) => GestureDetector(
                      onTap: () => _applyTag(tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.purple50,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(tag, style: const TextStyle(
                            fontSize: 12, color: AppColors.libPurple, fontWeight: FontWeight.w600)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Horizontal Category Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final selected = cat == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => ref.read(_searchCategoryProvider.notifier).state = cat,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.libPurple : Colors.white,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: selected ? AppColors.libPurple : AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_categoryIcons[cat], size: 14, color: selected ? Colors.white : AppColors.mutedForeground),
                                  const SizedBox(width: 6),
                                  Text(
                                    _categoryLabels[cat]!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? Colors.white : AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: isSearching
                ? _SkeletonList()
                : query.isEmpty
                  ? const _RecentlyViewedSection()
                  : _ResultsList(query: query, category: category),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recently Viewed (Empty State Carousel) ───────────────────────────────────

class _RecentlyViewedSection extends StatelessWidget {
  const _RecentlyViewedSection();

  static const _recent = [
    {'title': 'Scientific American April 2026', 'author': 'Springer Nature', 'type': 'magazine'},
    {'title': 'Time Magazine Spring 2026', 'author': 'Time USA, LLC', 'type': 'magazine'},
    {'title': 'National Geographic March 2026', 'author': 'National Geographic Society', 'type': 'magazine'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 18, color: AppColors.mutedForeground),
              SizedBox(width: 8),
              Text('Recently Viewed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _recent.length,
            itemBuilder: (context, i) {
              final item = _recent[i];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 140,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Center(
                            child: Icon(Icons.menu_book_rounded, color: AppColors.libPurple.withOpacity(0.3), size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(item['title']!, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.2)),
                      const SizedBox(height: 4),
                      Text(item['author']!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Shimmer skeleton list ─────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          height: 100,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}

// ── Real results list ────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final String query;
  final String category;
  const _ResultsList({required this.query, required this.category});

  static const _stub = [
    {'id': '1', 'title': 'Introduction to Algorithms', 'author': 'Cormen et al.', 'category': 'book', 'available': true},
    {'id': '1', 'title': 'Clean Code', 'author': 'Robert C. Martin', 'category': 'book', 'available': true},
    {'id': '2', 'title': 'Deep Learning', 'author': 'Goodfellow et al.', 'category': 'book', 'available': false},
    {'id': '1', 'title': 'Design Patterns', 'author': 'Gang of Four', 'category': 'book', 'available': true},
    {'id': '1', 'title': 'Database System Concepts', 'author': 'Silberschatz et al.', 'category': 'book', 'available': true},
    {'id': '1', 'title': 'ML: A Probabilistic Perspective', 'author': 'Kevin Murphy', 'category': 'research', 'available': true},
    {'id': '2', 'title': 'NeurIPS 2025 Proceedings', 'author': 'Various', 'category': 'research', 'available': false},
    {'id': '1', 'title': 'Scientific American April 2026', 'author': 'Springer Nature', 'category': 'magazine', 'available': true},
    {'id': '1', 'title': 'Time Magazine Spring 2026', 'author': 'Time USA, LLC', 'category': 'magazine', 'available': true},
    {'id': '1', 'title': 'National Geographic March 2026', 'author': 'National Geographic Society', 'category': 'magazine', 'available': true},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _stub.where((r) {
      final matchesQuery = query.isEmpty ||
          (r['title'] as String).toLowerCase().contains(query.toLowerCase()) ||
          (r['author'] as String).toLowerCase().contains(query.toLowerCase());
      final matchesCat = category == 'all' || r['category'] == category;
      return matchesQuery && matchesCat;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Kuwago Mascot Placeholder / Fallback
          Image.asset('assets/images/mascot_searching.png', height: 120,
            errorBuilder: (_, __, ___) => const Icon(Icons.search_off_rounded, size: 80, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),
          const Text('No results found', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Try adjusting your filters or search term.',
            style: TextStyle(color: AppColors.mutedForeground)),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Consumer(
        builder: (context, ref, _) => GestureDetector(
          onTap: () {
            ref.read(selectedResourceIdProvider.notifier).state = filtered[i]['id'] as String;
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourceDetailScreen()));
          },
          child: SearchResultCard(resource: filtered[i]),
        ),
      ),
    );
  }
}
