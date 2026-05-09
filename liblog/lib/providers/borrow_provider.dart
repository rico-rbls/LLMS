/// lib/providers/borrow_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BorrowRecord {
  final String id;
  final String bookTitle;
  final String author;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;

  BorrowRecord({
    required this.id, required this.bookTitle, required this.author,
    required this.borrowDate, required this.dueDate, this.returnDate,
  });

  bool get isReturned => returnDate != null;
  bool get isOverdue => !isReturned && DateTime.now().isAfter(dueDate);
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  int get daysOverdue => isOverdue ? DateTime.now().difference(dueDate).inDays : 0;
}

class BorrowNotifier extends Notifier<List<BorrowRecord>> {
  @override
  List<BorrowRecord> build() {
    final now = DateTime.now();
    // Stub data
    return [
      BorrowRecord(id: '1', bookTitle: 'Clean Code', author: 'Robert C. Martin', 
          borrowDate: now.subtract(const Duration(days: 5)), dueDate: now.add(const Duration(days: 9))),
      BorrowRecord(id: '2', bookTitle: 'Deep Learning', author: 'Ian Goodfellow', 
          borrowDate: now.subtract(const Duration(days: 20)), dueDate: now.subtract(const Duration(days: 6))), // Overdue
      BorrowRecord(id: '3', bookTitle: 'Design Patterns', author: 'Gang of Four', 
          borrowDate: now.subtract(const Duration(days: 15)), dueDate: now.subtract(const Duration(days: 1)), returnDate: now.subtract(const Duration(days: 2))), // History
    ];
  }

  void returnBook(String id) {
    state = state.map((b) => b.id == id ? BorrowRecord(
      id: b.id, bookTitle: b.bookTitle, author: b.author,
      borrowDate: b.borrowDate, dueDate: b.dueDate, returnDate: DateTime.now(),
    ) : b).toList();
  }
}

final borrowProvider = NotifierProvider<BorrowNotifier, List<BorrowRecord>>(BorrowNotifier.new);
