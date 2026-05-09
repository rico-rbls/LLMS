/// lib/screens/search_screen.dart
/// Catalog browser: 300ms debounced search, category pills, shimmer skeletons.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../config/colors.dart';

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
    final query      = ref.watch(_searchQueryProvider);
    final category   = ref.watch(_searchCategoryProvider);
    final isSearching = ref.watch(_isSearchingProvider);

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
                  const Text('Catalog', style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  const Text('Search books, research & more',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
                  const SizedBox(height: 16),

                  // Search input
                  TextField(
                    controller: _searchCtrl,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by title, author, subject...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.mutedForeground),
                      suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: AppColors.mutedForeground),
                            onPressed: _clearSearch,
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final selected = cat == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => ref
                                .read(_searchCategoryProvider.notifier)
                                .state = cat,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.libPurple
                                    : AppColors.purple50,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                _categoryLabels[cat]!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.libPurple,
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text('Popular Searches',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
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
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.trending_up_rounded,
                    size: 14, color: AppColors.libPurple),
                const SizedBox(width: 4),
                Text(tag, style: const TextStyle(
                    fontSize: 13, color: AppColors.libPurple,
                    fontWeight: FontWeight.w500)),
              ]),
            ),
          )).toList(),
        ),
        const SizedBox(height: 28),
        const Text('Browse by Category',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...['Books', 'Research Papers', 'Magazines'].map((cat) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.purple50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: AppColors.libPurple, size: 20),
          ),
          title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.mutedForeground),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: 4,
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
              color: Colors.grey.shade300,
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
                Container(height: 14, width: double.infinity,
                    color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Container(height: 12, width: 160, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Container(height: 10, width: 80, color: Colors.grey.shade200),
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
    {'title': 'Introduction to Algorithms', 'author': 'Cormen et al.', 'category': 'book', 'available': true},
    {'title': 'Clean Code', 'author': 'Robert C. Martin', 'category': 'book', 'available': true},
    {'title': 'Deep Learning', 'author': 'Goodfellow et al.', 'category': 'book', 'available': false},
    {'title': 'Design Patterns', 'author': 'Gang of Four', 'category': 'book', 'available': true},
    {'title': 'Database System Concepts', 'author': 'Silberschatz et al.', 'category': 'book', 'available': true},
    {'title': 'ML: A Probabilistic Perspective', 'author': 'Kevin Murphy', 'category': 'research', 'available': true},
    {'title': 'NeurIPS 2025 Proceedings', 'author': 'Various', 'category': 'research', 'available': false},
    {'title': 'National Geographic Mar 2026', 'author': 'Nat Geo Society', 'category': 'magazine', 'available': true},
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
          const Icon(Icons.search_off_rounded, size: 64,
              color: AppColors.mutedForeground),
          const SizedBox(height: 12),
          const Text('No results found', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Try a different search term',
            style: TextStyle(color: Colors.grey[500])),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text('${filtered.length} results for "$query"',
            style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ResourceCard(resource: filtered[i]),
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final Map<String, Object> resource;
  const _ResourceCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    final available = resource['available'] as bool;
    final category  = resource['category'] as String;
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Cover placeholder
          Container(
            width: 72, height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple200, AppColors.purple400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource['title'] as String,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 3),
                Text(resource['author'] as String,
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.mutedForeground)),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.purple50,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(category,
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.libPurple, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: available ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(available ? 'Available' : 'Unavailable',
                    style: TextStyle(fontSize: 11,
                        color: available ? Colors.green : Colors.red)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
