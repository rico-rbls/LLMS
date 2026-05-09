/// lib/screens/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../config/colors.dart';
import '../providers/resource_provider.dart';
import '../widgets/search_result_card.dart';
import 'resource_detail_screen.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _searchCategoryProvider = StateProvider<String>((ref) => 'all');
final _isSearchingProvider = StateProvider<bool>((ref) => false);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'All'},
    {'id': 'book', 'label': 'Books'},
    {'id': 'research', 'label': 'Research'},
    {'id': 'magazine', 'label': 'Magazines'},
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_searchQueryProvider);
    final selectedCat = ref.watch(_searchCategoryProvider);
    final isSearching = ref.watch(_isSearchingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.background,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Catalog',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search for books, research, magazines...',
                        hintStyle: GoogleFonts.inter(color: AppColors.mutedForeground, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mutedForeground),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isActive = selectedCat == cat['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => ref.read(_searchCategoryProvider.notifier).state = cat['id']!,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.libPurple : Colors.white,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: isActive ? AppColors.libPurple : AppColors.border,
                                ),
                                boxShadow: isActive ? [] : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                cat['label']!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : AppColors.libPurple,
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

            // Content
            Expanded(
              child: isSearching ? _buildSkeleton() : _buildResults(query, selectedCat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(String query, String category) {
    // Stub data matching resource_provider.dart or standard seed
    final List<Map<String, dynamic>> stubData = [
      {'id': '1', 'title': 'Scientific American April 2026', 'author': 'Springer Nature', 'category': 'magazine', 'available': true},
      {'id': '2', 'title': 'Time Magazine Spring 2026', 'author': 'Time USA, LLC', 'category': 'magazine', 'available': true},
      {'id': '3', 'title': 'National Geographic March 2026', 'author': 'National Geographic Society', 'category': 'magazine', 'available': false},
      {'id': '4', 'title': 'Introduction to Algorithms', 'author': 'Cormen et al.', 'category': 'book', 'available': true},
      {'id': '5', 'title': 'Deep Learning', 'author': 'Goodfellow et al.', 'category': 'book', 'available': true},
    ];

    final filtered = stubData.where((r) {
      final matchesQuery = r['title'].toLowerCase().contains(query.toLowerCase()) || 
                          r['author'].toLowerCase().contains(query.toLowerCase());
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
            Text(
              'No results found',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.foreground),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different search term or category',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedForeground),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return SearchResultCard(
          resource: filtered[index],
          onTap: () {
            ref.read(selectedResourceIdProvider.notifier).state = filtered[index]['id'];
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourceDetailScreen()));
          },
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
