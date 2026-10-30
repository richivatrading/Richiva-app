import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/notifications_provider.dart';
import '../../theme/app_theme.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification settings')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.s16),
          children: [
            const Text(
              'Choose what notifications you want to receive.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.s16),
            Card(
              child: Column(
                children: [
                  _CategoryTile(
                    category: NotificationCategory.orderUpdates,
                    enabled: settings[NotificationCategory.orderUpdates]!,
                    onChanged: (v) => ref
                        .read(notificationSettingsProvider.notifier)
                        .toggle(NotificationCategory.orderUpdates),
                  ),
                  _CategoryTile(
                    category: NotificationCategory.promotions,
                    enabled: settings[NotificationCategory.promotions]!,
                    onChanged: (v) => ref
                        .read(notificationSettingsProvider.notifier)
                        .toggle(NotificationCategory.promotions),
                  ),
                  _CategoryTile(
                    category: NotificationCategory.priceDrops,
                    enabled: settings[NotificationCategory.priceDrops]!,
                    onChanged: (v) => ref
                        .read(notificationSettingsProvider.notifier)
                        .toggle(NotificationCategory.priceDrops),
                  ),
                  _CategoryTile(
                    category: NotificationCategory.newArrivals,
                    enabled: settings[NotificationCategory.newArrivals]!,
                    onChanged: (v) => ref
                        .read(notificationSettingsProvider.notifier)
                        .toggle(NotificationCategory.newArrivals),
                  ),
                  _CategoryTile(
                    category: NotificationCategory.wishlistAlerts,
                    enabled: settings[NotificationCategory.wishlistAlerts]!,
                    onChanged: (v) => ref
                        .read(notificationSettingsProvider.notifier)
                        .toggle(NotificationCategory.wishlistAlerts),
                  ),
                  _CategoryTile(
                    category: NotificationCategory.referrals,
                    enabled: settings[NotificationCategory.referrals]!,
                    onChanged: (v) => ref
                        .read(notificationSettingsProvider.notifier)
                        .toggle(NotificationCategory.referrals),
                  ),
                  _CategoryTile(
                    category: NotificationCategory.system,
                    enabled: settings[NotificationCategory.system]!,
                    onChanged: (v) => ref
                        .read(notificationSettingsProvider.notifier)
                        .toggle(NotificationCategory.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.s16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(notificationSettingsProvider.notifier).setAll(false),
                    child: const Text('Disable all'),
                  ),
                ),
                const SizedBox(width: AppTheme.s12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        ref.read(notificationSettingsProvider.notifier).setAll(true),
                    child: const Text('Enable all'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.s24),
            const Text(
              'Note: System notifications (security, account changes) cannot be fully disabled.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  final NotificationCategory category;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _CategoryTile({
    required this.category,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      value: enabled,
      onChanged: onChanged,
      activeThumbColor: AppTheme.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.s16,
        vertical: 4,
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _iconColor(category).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.rMd),
            ),
            child: Icon(category.icon, size: 18, color: _iconColor(category)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        _description(category),
        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
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

  String _description(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.orderUpdates:
        return 'Shipping, delivery, and status updates';
      case NotificationCategory.promotions:
        return 'Sales, coupon codes, and special offers';
      case NotificationCategory.priceDrops:
        return 'Price reductions on products you\'ve viewed';
      case NotificationCategory.newArrivals:
        return 'Fresh drops and new collections';
      case NotificationCategory.wishlistAlerts:
        return 'Low stock or price changes on saved items';
      case NotificationCategory.referrals:
        return 'Referral rewards and friend activity';
      case NotificationCategory.system:
        return 'Security alerts and app updates';
    }
  }
}