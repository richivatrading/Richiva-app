import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/persisted_notifier.dart';

enum NotificationCategory {
  orderUpdates('Order updates', Icons.local_shipping_outlined),
  promotions('Promotions & offers', Icons.local_offer_outlined),
  priceDrops('Price drops', Icons.trending_down),
  newArrivals('New arrivals', Icons.new_releases_outlined),
  wishlistAlerts('Wishlist alerts', Icons.favorite_border),
  referrals('Referral updates', Icons.card_giftcard),
  system('System & security', Icons.settings_outlined);

  final String label;
  final IconData icon;
  const NotificationCategory(this.label, this.icon);
}

class NotificationItem {
  final String id;
  final NotificationCategory category;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute; // e.g. '/orders/ORD-2401'

  const NotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        category: category,
        title: title,
        body: body,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        actionRoute: actionRoute,
      );

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'actionRoute': actionRoute,
      };

  static NotificationItem fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as String,
        category: NotificationCategory.values.byName(j['category'] as String),
        title: j['title'] as String,
        body: j['body'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        isRead: j['isRead'] as bool? ?? false,
        actionRoute: j['actionRoute'] as String?,
      );
}

class NotificationsNotifier extends PersistedNotifier<List<NotificationItem>> {
  NotificationsNotifier()
      : super(
          storageKey: 'richiva.notifications.v1',
          seed: _seed(),
        );

  static List<NotificationItem> _seed() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: 'n1',
        category: NotificationCategory.orderUpdates,
        title: 'Order shipped',
        body: 'Your order ORD-2401 has been shipped and is on the way.',
        timestamp: now.subtract(const Duration(hours: 2)),
        actionRoute: '/orders/ORD-2401/track',
      ),
      NotificationItem(
        id: 'n2',
        category: NotificationCategory.promotions,
        title: 'Flash sale live!',
        body: 'Up to 50% off selected styles. Ends in 3 hours.',
        timestamp: now.subtract(const Duration(hours: 4)),
        actionRoute: '/shop/sale',
      ),
      NotificationItem(
        id: 'n3',
        category: NotificationCategory.priceDrops,
        title: 'Price drop on your wishlist item',
        body: 'Cashmere Sweater is now Rs. 3,499 (was Rs. 6,999).',
        timestamp: now.subtract(const Duration(hours: 8)),
        actionRoute: '/product/f1',
      ),
      NotificationItem(
        id: 'n4',
        category: NotificationCategory.newArrivals,
        title: 'New arrivals just landed',
        body: 'Fresh drops in Women\'s Dresses and Men\'s Shirts.',
        timestamp: now.subtract(const Duration(days: 1)),
        actionRoute: '/shop/women',
      ),
      NotificationItem(
        id: 'n5',
        category: NotificationCategory.wishlistAlerts,
        title: 'Low stock alert',
        body: 'Only 3 left of Silk Slip Dress in your wishlist.',
        timestamp: now.subtract(const Duration(days: 2)),
        actionRoute: '/product/f2',
      ),
      NotificationItem(
        id: 'n6',
        category: NotificationCategory.referrals,
        title: 'Referral reward earned!',
        body: 'Aarav used your code. You earned 500 Gold Points.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        actionRoute: '/loyalty',
      ),
      NotificationItem(
        id: 'n7',
        category: NotificationCategory.system,
        title: 'App update available',
        body: 'Version 1.2.0 includes performance improvements.',
        timestamp: now.subtract(const Duration(days: 5)),
        isRead: true,
      ),
    ];
  }

  @override
  dynamic serialize(List<NotificationItem> state) =>
      state.map((e) => e.toJson()).toList();

  @override
  List<NotificationItem> deserialize(dynamic json) =>
      (json as List).map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n
    ];
  }

  void markAllRead() {
    state = [
      for (final n in state) n.copyWith(isRead: true)
    ];
  }

  void add(NotificationItem item) {
    state = [item, ...state];
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  (_) => NotificationsNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

// Per-category toggles (persisted via shared_preferences in real app)
class NotificationSettingsNotifier extends PersistedNotifier<Map<NotificationCategory, bool>> {
  NotificationSettingsNotifier()
      : super(
          storageKey: 'richiva.notification_settings.v1',
          seed: {
            for (final c in NotificationCategory.values) c: true,
          },
        );

  @override
  dynamic serialize(Map<NotificationCategory, bool> state) =>
      state.map((c, v) => MapEntry(c.name, v));

  @override
  Map<NotificationCategory, bool> deserialize(dynamic json) {
    final map = json as Map<String, dynamic>;
    return map.map(
      (c, v) => MapEntry(NotificationCategory.values.byName(c), v as bool),
    );
  }

  void toggle(NotificationCategory c) {
    state = {
      ...state,
      c: !(state[c] ?? true),
    };
  }

  void setAll(bool v) {
    state = {
      for (final c in NotificationCategory.values) c: v,
    };
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, Map<NotificationCategory, bool>>(
  (_) => NotificationSettingsNotifier(),
);