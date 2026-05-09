import 'package:flutter/material.dart';
import '../config/colors.dart';

class SearchResultCard extends StatelessWidget {
  final Map<String, Object> resource;
  
  const SearchResultCard({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    final available = resource['available'] as bool;
    final category = resource['category'] as String;
    final primary = Theme.of(context).primaryColor; // #652D90

    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cover Placeholder
          Container(
            width: 72,
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purple200, AppColors.purple400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  resource['author'] as String,
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.purple50,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: available ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      available ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        fontSize: 11,
                        color: available ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
