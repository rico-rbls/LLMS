/// lib/widgets/reviews_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../config/colors.dart';
import '../providers/review_provider.dart';

class ReviewsWidget extends ConsumerStatefulWidget {
  final String resourceId;
  const ReviewsWidget({super.key, required this.resourceId});

  @override
  ConsumerState<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends ConsumerState<ReviewsWidget> {
  bool _isWriting = false;
  double _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) return;
    ref.read(reviewProvider.notifier).submitReview(widget.resourceId, _rating.toInt(), _commentCtrl.text);
    setState(() {
      _isWriting = false;
      _rating = 0;
      _commentCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(reviewProvider).where((r) => r.resourceId == widget.resourceId).toList();
    final hasReviewed = reviews.any((r) => r.isCurrentUser);

    final double avgRating = reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ratings & Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                  RatingBarIndicator(
                    rating: avgRating,
                    itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 14,
                  ),
                  const SizedBox(height: 4),
                  Text('${reviews.length} reviews', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = reviews.where((r) => r.rating == star).length;
                    final pct = reviews.isEmpty ? 0.0 : count / reviews.length;
                    return Row(
                      children: [
                        Text('$star', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        const Icon(Icons.star_rounded, size: 10, color: AppColors.mutedForeground),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 4,
                              backgroundColor: AppColors.purple50,
                              color: AppColors.libPurple,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Action Button
        if (!hasReviewed && !_isWriting)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _isWriting = true),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Write a Review'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.libPurple,
                side: const BorderSide(color: AppColors.libPurple),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

        // Inline Form
        if (_isWriting)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tap to Rate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: 0, minRating: 1, allowHalfRating: false,
                  itemCount: 5, itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                  onRatingUpdate: (r) => setState(() => _rating = r),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commentCtrl,
                  maxLength: 200,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Share your thoughts about this resource...',
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => setState(() => _isWriting = false), child: const Text('Cancel', style: TextStyle(color: AppColors.mutedForeground))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _rating > 0 ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.libPurple, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
        const SizedBox(height: 24),

        // Review List
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No reviews yet. Be the first to review!', style: TextStyle(color: AppColors.mutedForeground))),
          )
        else
          ...reviews.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.purple100,
                  child: Text(r.authorInitials, style: const TextStyle(color: AppColors.libPurple, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(r.authorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const Spacer(),
                          Text('${r.date.month}/${r.date.day}/${r.date.year}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                          if (r.isCurrentUser) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => ref.read(reviewProvider.notifier).deleteReview(r.id),
                              child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      RatingBarIndicator(
                        rating: r.rating.toDouble(),
                        itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                        itemCount: 5, itemSize: 12,
                      ),
                      const SizedBox(height: 8),
                      Text(r.comment, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
      ],
    );
  }
}
