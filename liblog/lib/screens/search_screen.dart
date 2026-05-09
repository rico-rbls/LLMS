/// lib/screens/search_screen.dart
/// Catalog browser: 300ms debounced search, category pills, shimmer skeletons.
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

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Always trigger shimmer if we're typing, unless clearing
    if (value.isNotEmpty) {
      ref.read(_isSearchingProvider.notifier).state = true;
    } else {
      ref.read(_isSearchingProvider.notifier).state = false;
    }
    
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(_searchQueryProvider.notifier).state = value;
        ref.read(_isSearchingProvider.notifier).state = false;
      }
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
    final query      = ref.watch(_searchQueryProvider);
    final category   = ref.watch(_searchCategoryProvider);
    final isSearching = ref.watch(_isSearchingProvider);
    final primary    = Theme.of(context).primaryColor; // #652D90

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Library',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Search books, research & more',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Search input
                  TextField(
                    controller: _searchCtrl,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by title, author, subject...',
                      hintStyle: const TextStyle(color: AppColors.mutedForeground),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mutedForeground),
                      suffixIcon: _searchCtrl.text.isNotEmpty || query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.mutedForeground),
                            onPressed: _clearSearch,
                          )
                        : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9999),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9999),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9999),
                        borderSide: BorderSide(color: primary.withOpacity(0.5), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category pills
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
                                color: selected ? primary : AppColors.purple50,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                _categoryLabels[cat]!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: isSearching
                ? _SkeletonList()
                : query.isEmpty
                  ? _EmptySearchBody(onTagTap: _applyTag)
                  : _ResultsList(query: query, category: category),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Popular tags + recently viewed (empty state) ──────────────────────────────

class _EmptySearchBody extends StatelessWidget {
  final ValueChanged<String> onTagTap;
  const _EmptySearchBody({required this.onTagTap});

  static const _tags = [
    'Algorithms', 'Deep Learning', 'Database',
    'Nursing', 'Psychology', 'Clean Code',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('Popular Searches', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _tags.map((tag) => GestureDetector(
            onTap: () => onTagTap(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purple50,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.libPurple),
                  const SizedBox(width: 4),
                  Text(tag, style: const TextStyle(fontSize: 13, color: AppColors.libPurple, fontWeight: FontWeight.w500)),
                ]
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 32),
        const Text('Browse by Category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...['Books', 'Research Papers', 'Magazines'].map((cat) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.purple50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.libPurple, size: 20),
          ),
          title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground),
        )),
      ],
    );
  }
}

// ── Shimmer skeleton list ─────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: const _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Cover placeholder
          Container(
            width: 72, height: 96,
            decoration: BoxDecoration(
              color: Colors.white, // Shimmer base color is grey
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Text placeholders
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(height: 12, width: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(height: 10, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ── Real results list (stubbed — will connect to API) ────────────────────────

class _ResultsList extends StatelessWidget {
  final String query;
  final String category;
  const _ResultsList({required this.query, required this.category});

  // Stub data — replace with real API call via resourcesProvider
  static const _stub = [
    {'id': '1', 'title': 'Introduction to Algorithms', 'author': 'Cormen et al.', 'category': 'book', 'available': true},
    {'id': '1', 'title': 'Clean Code', 'author': 'Robert C. Martin', 'category': 'book', 'available': true},
    {'id': '2', 'title': 'Deep Learning', 'author': 'Goodfellow et al.', 'category': 'book', 'available': false},
    {'id': '1', 'title': 'Design Patterns', 'author': 'Gang of Four', 'category': 'book', 'available': true},
    {'id': '1', 'title': 'Database System Concepts', 'author': 'Silberschatz et al.', 'category': 'book', 'available': true},
    {'id': '1', 'title': 'ML: A Probabilistic Perspective', 'author': 'Kevin Murphy', 'category': 'research', 'available': true},
    {'id': '2', 'title': 'NeurIPS 2025 Proceedings', 'author': 'Various', 'category': 'research', 'available': false},
    {'id': '1', 'title': 'National Geographic Mar 2026', 'author': 'Nat Geo Society', 'category': 'magazine', 'available': true},
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.mutedForeground),
            const SizedBox(height: 16),
            const Text('No results found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Try a different search term or category.', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ]
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            '${filtered.length} results for "$query"',
            style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)
          ),
        ),
        Expanded(
          child: ListView.separated(
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
          ),
        ),
      ],
    );
  }
}
