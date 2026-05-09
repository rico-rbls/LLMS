/// lib/providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationRecord {
  final String id;
  final String type; // due_date, reservation, announcement
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  NotificationRecord({
    required this.id, required this.type, required this.title,
    required this.message, required this.createdAt, this.isRead = false,
  });
}

class NotificationNotifier extends Notifier<List<NotificationRecord>> {
  @override
  List<NotificationRecord> build() {
    final now = DateTime.now();
    return [
      NotificationRecord(id: '1', type: 'due_date', title: 'Book Due Soon', message: 'Clean Code is due in 3 days.', createdAt: now.subtract(const Duration(hours: 2))),
      NotificationRecord(id: '2', type: 'reservation', title: 'Reservation Ready', message: 'Deep Learning is now available for pickup.', createdAt: now.subtract(const Duration(days: 1))),
      NotificationRecord(id: '3', type: 'announcement', title: 'Library Hours Extended', message: 'Open until 10PM for finals week.', createdAt: now.subtract(const Duration(days: 2)), isRead: true),
    ];
  }

  void markAllAsRead() {
    state = state.map((n) => NotificationRecord(
      id: n.id, type: n.type, title: n.title, message: n.message, createdAt: n.createdAt, isRead: true
    )).toList();
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, List<NotificationRecord>>(NotificationNotifier.new);
