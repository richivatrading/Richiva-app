import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/notifications_provider.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.s16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppTheme.s8),
              itemBuilder: (_, i) =>
                  _NotificationTile(notification: notifications[i]),
            ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppTheme.border,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_outlined,
                  size: 40, color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.s24),
            Text('No notifications yet',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppTheme.s8),
            const Text(
              'We\'ll notify you about orders, offers, and more.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationItem notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead = notification.isRead;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      onTap: () {
        if (!isRead) {
          ref.read(notificationsProvider.notifier).markRead(notification.id);
        }
        if (notification.actionRoute != null) {
          context.push(notification.actionRoute!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppTheme.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          border: Border.all(
            color: isRead ? AppTheme.border : AppTheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _iconColor(notification.category).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.rMd),
              ),
              child: Icon(
                notification.category.icon,
                size: 18,
                color: _iconColor(notification.category),
              ),
            ),
            const SizedBox(width: AppTheme.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.timeAgo,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _iconColor(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.orderUpdates:
        return const Color(0xFF3B82F6);
      case NotificationCategory.promotions:
      case NotificationCategory.priceDrops:
        return AppTheme.gold;
      case NotificationCategory.newArrivals:
        return const Color(0xFF16A34A);
      case NotificationCategory.wishlistAlerts:
        return AppTheme.danger;
      case NotificationCategory.referrals:
        return AppTheme.gold;
      case NotificationCategory.system:
        return AppTheme.textMuted;
    }
  }
}