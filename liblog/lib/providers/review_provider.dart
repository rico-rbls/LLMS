/// lib/providers/review_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Review {
  final String id;
  final String resourceId;
  final String authorName;
  final String authorInitials;
  final int rating;
  final String comment;
  final DateTime date;
  final bool isCurrentUser;

  Review({
    required this.id, required this.resourceId, required this.authorName,
    required this.authorInitials, required this.rating, required this.comment,
    required this.date, this.isCurrentUser = false,
  });
}

class ReviewNotifier extends Notifier<List<Review>> {
  @override
  List<Review> build() {
    return [
      Review(id: '1', resourceId: '1', authorName: 'Maria S.', authorInitials: 'MS', rating: 5, comment: 'Must read for every developer!', date: DateTime.now().subtract(const Duration(days: 2))),
      Review(id: '2', resourceId: '1', authorName: 'Alex R.', authorInitials: 'AR', rating: 4, comment: 'Great concepts, but a bit dated.', date: DateTime.now().subtract(const Duration(days: 14))),
    ];
  }

  void submitReview(String resourceId, int rating, String comment) {
    final newReview = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      resourceId: resourceId,
      authorName: 'Juan D.',
      authorInitials: 'JD',
      rating: rating,
      comment: comment,
      date: DateTime.now(),
      isCurrentUser: true,
    );
    state = [newReview, ...state];
  }

  void deleteReview(String id) {
    state = state.where((r) => r.id != id).toList();
  }
}

final reviewProvider = NotifierProvider<ReviewNotifier, List<Review>>(ReviewNotifier.new);
