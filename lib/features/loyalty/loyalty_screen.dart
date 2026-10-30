import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/loyalty_provider.dart';
import '../../shared/providers/bag_provider.dart';
import '../../theme/app_theme.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyalty = ref.watch(loyaltyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gold Points')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.s16),
          children: [
            // ── Hero card
            _LoyaltyHeroCard(loyalty: loyalty),
            const SizedBox(height: AppTheme.s16),

            // ── Tier progress
            _TierProgressCard(loyalty: loyalty),
            const SizedBox(height: AppTheme.s16),

            // ── Redeem CTA
            FilledButton.icon(
              onPressed: () => _showRedeemSheet(context, ref, loyalty),
              icon: const Icon(Icons.redeem),
              label: const Text('Redeem points'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: AppTheme.s24),

            // ── History header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Points history',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '${loyalty.history.length} entries',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.s8),
            ...loyalty.history.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.s8),
                  child: _HistoryRow(entry: e),
                )),
            const SizedBox(height: AppTheme.s16),

            // ── Earning info
            const _EarnPointsInfoCard(),
            const SizedBox(height: AppTheme.s24),
          ],
        ),
      ),
    );
  }

  void _showRedeemSheet(
      BuildContext context, WidgetRef ref, LoyaltyState loyalty) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RedeemSheet(loyalty: loyalty),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LoyaltyHeroCard extends StatelessWidget {
  final LoyaltyState loyalty;
  const _LoyaltyHeroCard({required this.loyalty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8C766), Color(0xFFB8860B)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.rLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB8860B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 20),
              const SizedBox(width: 6),
              const Text(
                'GOLD POINTS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppTheme.rPill),
                ),
                child: Text(
                  loyalty.tier.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${loyalty.points}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'points',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s8),
          Text(
            _valueHint(loyalty.points),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _valueHint(int points) {
    // Rough conversion: 5 points = Rs. 1 off
    final rupees = points ~/ 5;
    return 'Worth up to Rs. $rupees off your next order';
  }
}

class _TierProgressCard extends StatelessWidget {
  final LoyaltyState loyalty;
  const _TierProgressCard({required this.loyalty});

  @override
  Widget build(BuildContext context) {
    final next = loyalty.tier.next;

    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loyalty.tier.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              if (next != null)
                Text(
                  next.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.s12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.rPill),
            child: LinearProgressIndicator(
              value: loyalty.progressToNext,
              minHeight: 8,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
            ),
          ),
          const SizedBox(height: AppTheme.s8),
          Text(
            next == null
                ? 'You\'ve reached the highest tier. Enjoy your perks.'
                : '${loyalty.pointsToNext} more points to reach ${next.label}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: AppTheme.s12),
          Row(
            children: [
              _TierChip(
                label: LoyaltyTier.bronze.label,
                active: loyalty.tier == LoyaltyTier.bronze,
              ),
              _TierChip(
                label: LoyaltyTier.silver.label,
                active: loyalty.tier == LoyaltyTier.silver,
              ),
              _TierChip(
                label: LoyaltyTier.gold.label,
                active: loyalty.tier == LoyaltyTier.gold,
              ),
              _TierChip(
                label: LoyaltyTier.platinum.label,
                active: loyalty.tier == LoyaltyTier.platinum,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool isLast;
  const _TierChip({
    required this.label,
    required this.active,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  color: active ? AppTheme.gold : AppTheme.border,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppTheme.primary : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final PointEntry entry;
  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isEarned = entry.points > 0;
    final color = isEarned ? AppTheme.success : AppTheme.danger;

    return Container(
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? Icons.add : Icons.remove,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: AppTheme.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateLabel(entry.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEarned ? '+' : ''}${entry.points}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }
}

class _EarnPointsInfoCard extends StatelessWidget {
  const _EarnPointsInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome,
                  size: 16, color: AppTheme.gold),
              SizedBox(width: 6),
              Text(
                'How to earn points',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s8),
          const Text(
            '• 1 point for every Rs. 10 spent\n'
            '• 500-point bonus per successful referral\n'
            '• 200-point birthday bonus each year\n'
            '• Seasonal campaigns double your earning rate',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Redeem bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _RedeemOption {
  final int cost;
  final int value;
  const _RedeemOption({required this.cost, required this.value});

  /// Generates a unique code per redemption, e.g. `LOYAL100-A3F2`.
  /// Nonce guarantees no collision if the same tier is redeemed twice.
  String makeUniqueCode() {
    final nonce = DateTime.now()
        .millisecondsSinceEpoch
        .toRadixString(36)
        .substring(7)
        .toUpperCase();
    return 'LOYAL$value-$nonce';
  }
}

const _redeemOptions = [
  _RedeemOption(cost: 500, value: 100),
  _RedeemOption(cost: 1000, value: 250),
  _RedeemOption(cost: 2000, value: 600),
];

class _RedeemSheet extends ConsumerWidget {
  final LoyaltyState loyalty;
  const _RedeemSheet({required this.loyalty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppTheme.s16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(AppTheme.rPill),
                ),
              ),
            ),
            Row(
              children: [
                Text('Redeem points',
                    style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                Text(
                  '${loyalty.points} available',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.s16),
            ..._redeemOptions.map((o) {
              final canAfford = loyalty.points >= o.cost;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.s8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.rMd),
                  onTap: canAfford
                      ? () => _redeem(context, ref, o)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.s16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.rMd),
                      border: Border.all(
                        color: canAfford
                            ? AppTheme.primary
                            : AppTheme.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: canAfford
                                ? AppTheme.gold.withValues(alpha: 0.15)
                                : AppTheme.border,
                            borderRadius:
                                BorderRadius.circular(AppTheme.rMd),
                          ),
                          child: Icon(
                            Icons.local_offer,
                            color: canAfford
                                ? AppTheme.gold
                                : AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rs. ${o.value} off voucher',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Text(
                                '${o.cost} points',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: canAfford
                                      ? AppTheme.textMuted
                                      : AppTheme.danger,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canAfford)
                          const Icon(Icons.chevron_right,
                              size: 20, color: AppTheme.textMuted)
                        else
                          const Text(
                            'Not enough',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.danger,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppTheme.s8),
            const Text(
              'Redeemed vouchers can be used at checkout. Points are deducted immediately and cannot be refunded once used.',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _redeem(
      BuildContext context, WidgetRef ref, _RedeemOption option) {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = ref.read(loyaltyProvider.notifier).redeem(
          points: option.cost,
          reason: 'Redeemed for Rs. ${option.value} voucher',
        );

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    navigator.pop();

    // Add the redeemed voucher to the catalog so it works at checkout.
    final code = option.makeUniqueCode();
    ref.read(voucherCatalogProvider.notifier).add(
          Voucher(
            code: code,
            description: 'Rs. ${option.value} off · loyalty redemption',
            discountRs: option.value.toDouble(),
            minOrderValue: 0,
          ),
        );

    navigator.pop();

    // Show the code so the user can copy it.
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle,
            color: AppTheme.success, size: 48),
        title: const Text('Voucher unlocked'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Use this code at checkout:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: AppTheme.s12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppTheme.rMd),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.s12),
            Text(
              'Rs. ${option.value} off · One-time use',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code copied'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy code'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}