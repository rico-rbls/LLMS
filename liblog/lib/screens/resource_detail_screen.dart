/// lib/screens/resource_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../providers/resource_provider.dart';
import '../widgets/reviews_widget.dart';

class ResourceDetailScreen extends ConsumerStatefulWidget {
  const ResourceDetailScreen({super.key});

  @override
  ConsumerState<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends ConsumerState<ResourceDetailScreen> {
  bool _isFavorite = false;

  void _showShareToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resourceId = ref.watch(selectedResourceIdProvider);
    if (resourceId == null) return const Scaffold(body: Center(child: Text('Error: No resource selected')));

    final resourceList = ref.watch(resourceProvider);
    final resource = resourceList.firstWhere((r) => r.id == resourceId, orElse: () => resourceList.first);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with Gradient & Circles
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.libPurple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () {
                ref.read(selectedResourceIdProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share_rounded, color: Colors.white), onPressed: _showShareToast),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.libPurple, AppColors.purple800],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(top: -40, right: -40, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
                  Positioned(bottom: -20, left: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Background overlapping header
                Container(
                  margin: const EdgeInsets.only(top: 120), // Leave space for cover
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(resource.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(resource.author, style: const TextStyle(fontSize: 16, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isFavorite = !_isFavorite),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                              child: Icon(
                                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: _isFavorite ? Colors.red : AppColors.mutedForeground,
                                size: 24,
                              ).animate(target: _isFavorite ? 1 : 0).scale(begin: const Offset(1,1), end: const Offset(1.2,1.2), duration: 200.ms).then().scale(begin: const Offset(1.2,1.2), end: const Offset(1,1)),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Badges
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          _buildBadge(resource.isAvailable ? 'Available' : 'Unavailable', resource.isAvailable ? Colors.green : Colors.red, Icons.check_circle_rounded),
                          _buildBadge(resource.shelfLocation, AppColors.libPurple, Icons.pin_drop_rounded),
                          _buildBadge(resource.subject, Colors.blue, Icons.category_rounded),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      const Text('About this book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(resource.abstractText, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.mutedForeground)),
                      
                      const SizedBox(height: 16),
                      // Details Grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                        child: Row(
                          children: [
                            Expanded(child: _buildDetailItem('Published', resource.publicationDate)),
                            Expanded(child: _buildDetailItem('ISBN', resource.isbn)),
                            Expanded(child: _buildDetailItem('Type', resource.category.toUpperCase())),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Reviews Component
                      ReviewsWidget(resourceId: resource.id),
                    ],
                  ),
                ),

                // Floating Book Cover
                Positioned(
                  top: 20, left: 20,
                  child: Hero(
                    tag: 'cover_${resource.id}',
                    child: Container(
                      width: 120, height: 160,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.purple300, AppColors.purple600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
                      ),
                      child: const Center(child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 48)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Sticky Bottom Action Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () {
            if (!resource.isAvailable) {
              ref.read(resourceProvider.notifier).reserve(resource.id);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reservation placed successfully!')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Borrow process started...')));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: resource.isAvailable ? AppColors.libPurple : Colors.transparent,
            foregroundColor: resource.isAvailable ? Colors.white : AppColors.libPurple,
            elevation: resource.isAvailable ? 2 : 0,
            side: resource.isAvailable ? BorderSide.none : const BorderSide(color: AppColors.libPurple, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(resource.isAvailable ? 'Borrow Now' : 'Reserve Copy', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
