/// lib/screens/resource_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
      SnackBar(
        content: Text('Copied to clipboard!', style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Collapsing App Bar with Cover Effect
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.libPurple,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    onPressed: _showShareToast,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.2,
                  title: Text(
                    resource.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient Background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.libPurple, AppColors.purple800],
                          ),
                        ),
                      ),
                      // Large Centered Cover
                      Center(
                        child: Container(
                          width: 140,
                          height: 200,
                          margin: const EdgeInsets.only(top: 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 64),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                ),
              ),

              // Content Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resource.title,
                                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        resource.author,
                                        style: GoogleFonts.inter(fontSize: 16, color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: _isFavorite ? Colors.red : AppColors.mutedForeground,
                                  ),
                                  onPressed: () => setState(() => _isFavorite = !_isFavorite),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Quick Badges
                            Row(
                              children: [
                                _buildStatusBadge(resource.isAvailable),
                                const SizedBox(width: 8),
                                _buildBadge(resource.category.toUpperCase(), AppColors.libPurple),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Metadata Grid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetadata('ISBN', resource.isbn),
                                _buildMetadata('PUBLISHED', resource.publicationDate),
                                _buildMetadata('SHELF', resource.shelfLocation),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // About Section
                      Text('About this book', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text(
                        resource.abstractText,
                        style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.mutedForeground),
                      ),

                      const SizedBox(height: 24),
                      // Tags Section
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: resource.subject.split(',').map((s) => _buildBadge(s.trim(), AppColors.mutedForeground)).toList(),
                      ),

                      const SizedBox(height: 32),
                      // Reviews Integration
                      ReviewsWidget(resourceId: resource.id),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (resource.isAvailable) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Borrow request...', style: GoogleFonts.inter())),
                          );
                        } else {
                          ref.read(resourceProvider.notifier).reserve(resource.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reservation placed!', style: GoogleFonts.inter())),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.libPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        resource.isAvailable ? 'Borrow Book' : 'Reserve Book',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Secondary Share Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.purple50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share_rounded, color: AppColors.libPurple),
                      onPressed: _showShareToast,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: available ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: available ? Colors.green : Colors.red),
          const SizedBox(width: 6),
          Text(
            available ? 'Available' : 'Unavailable',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: available ? Colors.green : Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildMetadata(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground),
        ),
      ],
    );
  }
}
