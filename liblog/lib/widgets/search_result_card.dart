import 'package:flutter/material.dart';
import '../config/colors.dart';

class SearchResultCard extends StatelessWidget {
  final Map<String, Object> resource;
  const SearchResultCard({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    final available = resource['available'] as bool;
    final category  = resource['category'] as String;
    
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Cover Thumbnail
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/covers/cover_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(child: Icon(Icons.menu_book_rounded, color: Colors.white70, size: 24)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource['title'] as String,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(resource['author'] as String,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Dynamic Category Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.purple50,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(category.toUpperCase(),
                        style: const TextStyle(fontSize: 9, color: AppColors.libPurple, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 6),
                    // Hardcoded extra tag just for UI completeness from the spec
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Text('science',
                        style: TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    // Availability Indicator
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: available ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(available ? '2/2' : '0/2',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: available ? Colors.green : Colors.red)),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
