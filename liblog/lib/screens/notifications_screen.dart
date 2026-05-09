/// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.foreground),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Notifications', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w700)),
          actions: [
            if (unreadCount > 0)
              TextButton(
                onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
                child: const Text('Mark all read', style: TextStyle(color: AppColors.libPurple, fontWeight: FontWeight.w600)),
              ),
          ],
          bottom: TabBar(
            labelColor: AppColors.libPurple,
            unselectedLabelColor: AppColors.mutedForeground,
            indicatorColor: AppColors.libPurple,
            tabs: [
              const Tab(text: 'All'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unread'),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.libPurple, shape: BoxShape.circle),
                        child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ]
                  ],
                ),
              ),
              const Tab(text: 'Mentions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, ref, notifications),
            _buildList(context, ref, notifications.where((n) => !n.isRead).toList()),
            _buildList(context, ref, notifications.where((n) => n.type == 'reservation').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<NotificationRecord> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No notifications here', style: TextStyle(color: AppColors.mutedForeground)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final n = items[index];
        return Dismissible(
          key: Key(n.id),
          direction: DismissDirection.endToStart,
          dismissThresholds: const {DismissDirection.endToStart: 0.3},
          onDismissed: (_) => ref.read(notificationProvider.notifier).dismiss(n.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          child: _NotificationCard(notification: n),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).slideX(begin: 0.1, end: 0);
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationRecord notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case 'due_date':
        typeColor = Colors.orange;
        typeIcon = Icons.access_time_filled_rounded;
        break;
      case 'reservation':
        typeColor = AppColors.libPurple;
        typeIcon = Icons.bookmark_rounded;
        break;
      default:
        typeColor = Colors.blue;
        typeIcon = Icons.campaign_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, decoration: BoxDecoration(color: typeColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14))),
                        if (!notification.isRead)
                          Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 8, right: 16), decoration: const BoxDecoration(color: AppColors.libPurple, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(notification.message, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                    ),
                    const SizedBox(height: 8),
                    Text('${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
