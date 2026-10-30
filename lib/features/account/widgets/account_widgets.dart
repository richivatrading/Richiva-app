import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/order.dart';
import '../../../shared/models/product.dart';
import '../../../shared/providers/bag_provider.dart';
import '../../../shared/providers/loyalty_provider.dart';
import '../../../shared/providers/orders_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/notifications_provider.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile header
// ─────────────────────────────────────────────────────────────────────────────
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.s16, AppTheme.s16, AppTheme.s16, AppTheme.s8,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primary,
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since ${_monthYear(user.memberSince)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editProfile(context, ref, user),
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Edit profile',
          ),
        ],
      ),
    );
  }

  String _monthYear(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Future<void> _editProfile(
      BuildContext context, WidgetRef ref, User user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(userProvider.notifier).update(
                    user.copyWith(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gold Points card
// ─────────────────────────────────────────────────────────────────────────────
class GoldPointsCard extends ConsumerWidget {
  const GoldPointsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyalty = ref.watch(loyaltyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.rLg),
        onTap: () => context.push('/loyalty'),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.s16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8C766), Color(0xFFB8860B)],
            ),
            borderRadius: BorderRadius.circular(AppTheme.rLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'GOLD POINTS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppTheme.rPill),
                    ),
                    child: Text(
                      loyalty.tier.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.s12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${loyalty.points}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'points',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.s12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.rPill),
                child: LinearProgressIndicator(
                  value: loyalty.progressToNext,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: AppTheme.s8),
              Text(
                loyalty.tier.next == null
                    ? 'You\'ve reached the highest tier!'
                    : '${loyalty.pointsToNext} more points to ${loyalty.tier.next!.label}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Services grid (4×2) — Orders, Vouchers, Wishlist, Returns,
// Notifications, Support, Size Guide, Referrals
// ─────────────────────────────────────────────────────────────────────────────
class ServicesGrid extends ConsumerWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherCount = ref.watch(voucherCatalogProvider).length;
    final unread = ref.watch(unreadCountProvider);

    final services = <_ServiceEntry>[
      _ServiceEntry(
        icon: Icons.receipt_long_outlined,
        label: 'Orders',
        route: '/orders',
      ),
      _ServiceEntry(
        icon: Icons.local_offer_outlined,
        label: 'Vouchers',
        route: '/vouchers',
        badge: voucherCount > 0 ? '$voucherCount' : null,
      ),
      _ServiceEntry(
        icon: Icons.favorite_border,
        label: 'Wishlist',
        route: '/wishlist',
      ),
      _ServiceEntry(
        icon: Icons.assignment_return_outlined,
        label: 'Returns',
        route: '/returns',
      ),
      _ServiceEntry(
        icon: Icons.notifications_outlined,
        label: 'Alerts',
        route: '/notifications',
        badge: unread > 0 ? '$unread' : null,
      ),
      _ServiceEntry(
        icon: Icons.support_agent,
        label: 'Support',
        route: '/support',
      ),
      _ServiceEntry(
        icon: Icons.straighten,
        label: 'Size Guide',
        route: '/size-guide',
      ),
      _ServiceEntry(
        icon: Icons.card_giftcard,
        label: 'Referrals',
        route: '/referrals',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.rLg),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            for (var row = 0; row < 2; row++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: row == 0 ? AppTheme.s16 : 0,
                ),
                child: Row(
                  children: [
                    for (var col = 0; col < 4; col++)
                      Expanded(
                        child: _ServiceTile(
                          entry: services[row * 4 + col],
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
}

class _ServiceEntry {
  final IconData icon;
  final String label;
  final String route;
  final String? badge;
  const _ServiceEntry({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
  });
}

class _ServiceTile extends StatelessWidget {
  final _ServiceEntry entry;
  const _ServiceTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(entry.route),
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.s8),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(AppTheme.rMd),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Icon(entry.icon, size: 20, color: AppTheme.primary),
                ),
                if (entry.badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.danger,
                        borderRadius: BorderRadius.circular(AppTheme.rPill),
                      ),
                      child: Text(
                        entry.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              entry.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order status tabs
// ─────────────────────────────────────────────────────────────────────────────
class OrderStatusTabs extends ConsumerWidget {
  const OrderStatusTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final returns = ref.watch(returnsProvider);

    int count(OrderStatus s) => orders.where((o) => o.status == s).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.s12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.rLg),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            _StatusTab(
              icon: Icons.payment,
              label: 'To pay',
              count: count(OrderStatus.toPay),
              onTap: () => context.push('/orders'),
            ),
            _StatusTab(
              icon: Icons.inventory_2_outlined,
              label: 'To ship',
              count: count(OrderStatus.toShip),
              onTap: () => context.push('/orders'),
            ),
            _StatusTab(
              icon: Icons.local_shipping_outlined,
              label: 'To receive',
              count: count(OrderStatus.toReceive),
              onTap: () => context.push('/orders'),
            ),
            _StatusTab(
              icon: Icons.rate_review_outlined,
              label: 'To review',
              count: count(OrderStatus.toReview),
              onTap: () => context.push('/orders'),
            ),
            _StatusTab(
              icon: Icons.assignment_return_outlined,
              label: 'Returns',
              count: returns.length,
              onTap: () => context.push('/returns'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;
  const _StatusTab({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 22, color: AppTheme.primary),
                  if (count > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.danger,
                          borderRadius:
                              BorderRadius.circular(AppTheme.rPill),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recently viewed rail
// ─────────────────────────────────────────────────────────────────────────────
class RecentlyViewedSection extends ConsumerWidget {
  final List<Product> products;
  const RecentlyViewedSection({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.s16, AppTheme.s24, AppTheme.s16, AppTheme.s12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recently viewed',
                  style: Theme.of(context).textTheme.titleLarge),
              Text(
                '${products.length} item${products.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppTheme.s12),
            itemBuilder: (_, i) => ProductCard(
              product: products[i],
              width: 130,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active offers
// ─────────────────────────────────────────────────────────────────────────────
class ActiveOffersSection extends ConsumerWidget {
  const ActiveOffersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(voucherCatalogProvider).values.take(3).toList();
    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.s16, AppTheme.s24, AppTheme.s16, AppTheme.s12,
          ),
          child: Text('Active offers',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
            itemCount: offers.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppTheme.s12),
            itemBuilder: (_, i) => _OfferCard(voucher: offers[i]),
          ),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Voucher voucher;
  const _OfferCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      onTap: () {
        Clipboard.setData(ClipboardData(text: voucher.code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code ${voucher.code} copied'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.rMd),
              ),
              child: const Icon(Icons.local_offer,
                  color: AppTheme.gold, size: 22),
            ),
            const SizedBox(width: AppTheme.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    voucher.code,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    voucher.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voucher.minOrderValue > 0
                        ? 'Min. Rs. ${voucher.minOrderValue.toStringAsFixed(0)}'
                        : 'No minimum',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Care links (trimmed — notifications + size guide moved to services grid)
// ─────────────────────────────────────────────────────────────────────────────
class CareLinksSection extends ConsumerWidget {
  const CareLinksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.s16, AppTheme.s24, AppTheme.s16, AppTheme.s32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.s12),
            child: Text('Help & Settings',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.rLg),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _CareLink(
                  icon: Icons.chat_bubble_outline,
                  label: 'Live chat',
                  onTap: () => context.push('/support/chat'),
                ),
                _CareLink(
                  icon: Icons.smart_toy_outlined,
                  label: 'AI assistant',
                  onTap: () => context.push('/support/ai'),
                ),
                _CareLink(
                  icon: Icons.settings_outlined,
                  label: 'Notification settings',
                  onTap: () => context.push('/notifications/settings'),
                ),
                _CareLink(
                  icon: Icons.info_outline,
                  label: 'About Richiva',
                  onTap: () => _aboutDialog(context),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.s16),
          OutlinedButton(
            onPressed: () => _confirmSignOut(context, ref),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppTheme.border),
              foregroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.rMd),
              ),
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  void _aboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Richiva',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '© ${DateTime.now().year} Richiva. All rights reserved.',
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(userProvider.notifier).signOut();
      context.go('/login');
    }
  }
}

class _CareLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  const _CareLink({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isLast ? Radius.zero : const Radius.circular(0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.s16,
          vertical: AppTheme.s16,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppTheme.border, width: 1),
                ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: AppTheme.s12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}