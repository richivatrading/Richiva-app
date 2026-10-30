import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/bag_provider.dart';
import '../../theme/app_theme.dart';

class VouchersScreen extends ConsumerWidget {
  const VouchersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(bagSubtotalProvider);
    final appliedVoucher = ref.watch(voucherProvider);
    final vouchers = ref.watch(voucherCatalogProvider).values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Voucher Center')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.s16),
          children: [
            // ── Bag context banner
            _BagContextBanner(
              subtotal: subtotal,
              onShop: () => context.go('/'),
            ),
            const SizedBox(height: AppTheme.s16),

            // ── Applied voucher highlight
            if (appliedVoucher != null) ...[
              const Text(
                'Currently applied',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AppTheme.s8),
              _AppliedVoucherCard(voucher: appliedVoucher),
              const SizedBox(height: AppTheme.s16),
            ],

            // ── All vouchers
            const Text(
              'Available vouchers',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: AppTheme.s8),
            ...vouchers.map((v) {
              final eligible = subtotal >= v.minOrderValue;
              final isApplied = appliedVoucher?.code == v.code;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.s12),
                child: _VoucherCard(
                  voucher: v,
                  eligible: eligible,
                  isApplied: isApplied,
                  subtotal: subtotal,
                  onApply: isApplied
                      ? null
                      : () {
                          final catalog = ref.read(voucherCatalogProvider);
                          final error = ref
                              .read(voucherProvider.notifier)
                              .applyCode(v.code, subtotal, catalog);
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${v.code} applied. ${v.description}.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  onRemove: isApplied
                      ? () {
                          ref.read(voucherProvider.notifier).remove();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Voucher removed')),
                          );
                        }
                      : null,
                ),
              );
            }),

            const SizedBox(height: AppTheme.s16),

            // ── How it works
            const _HowItWorksCard(),
            const SizedBox(height: AppTheme.s24),

            // ── CTA back to bag
            if (subtotal > 0)
              FilledButton.icon(
                onPressed: () => context.push('/bag'),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Go to bag'),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BagContextBanner extends StatelessWidget {
  final double subtotal;
  final VoidCallback onShop;

  const _BagContextBanner({required this.subtotal, required this.onShop});

  @override
  Widget build(BuildContext context) {
    if (subtotal <= 0) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.s16),
        decoration: BoxDecoration(
          color: AppTheme.border.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.rMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline,
                size: 20, color: AppTheme.textMuted),
            const SizedBox(width: AppTheme.s12),
            const Expanded(
              child: Text(
                'Your bag is empty. Voucher eligibility is based on bag value.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ),
            TextButton(
              onPressed: onShop,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Shop'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.rMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 20, color: AppTheme.primary),
          const SizedBox(width: AppTheme.s12),
          Expanded(
            child: Text(
              'Bag value: Rs. ${subtotal.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppliedVoucherCard extends StatelessWidget {
  final Voucher voucher;
  const _AppliedVoucherCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(
          color: AppTheme.success.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.rMd),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppTheme.success, size: 22),
          ),
          const SizedBox(width: AppTheme.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  voucher.description,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final bool eligible;
  final bool isApplied;
  final double subtotal;
  final VoidCallback? onApply;
  final VoidCallback? onRemove;

  const _VoucherCard({
    required this.voucher,
    required this.eligible,
    required this.isApplied,
    required this.subtotal,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final shortfall = (voucher.minOrderValue - subtotal).clamp(0, 1e9);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(
          color: isApplied ? AppTheme.success : AppTheme.border,
          width: isApplied ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tear-off style left block
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: eligible
                          ? [const Color(0xFFE8C766), const Color(0xFFB8860B)]
                          : [AppTheme.border, AppTheme.border],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.rMd),
                  ),
                  child: Center(
                    child: _discountLabel(voucher, eligible),
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
                              voucher.description,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          if (eligible)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.success
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.rPill),
                              ),
                              child: const Text(
                                'Eligible',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.success,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            voucher.code,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: voucher.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${voucher.code} copied'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Icon(Icons.copy,
                                size: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voucher.minOrderValue > 0
                            ? 'Min. order Rs. ${voucher.minOrderValue.toStringAsFixed(0)}'
                            : 'No minimum order',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted),
                      ),
                      if (!eligible && shortfall > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Add Rs. ${shortfall.toStringAsFixed(0)} more to unlock',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.all(AppTheme.s12),
            child: isApplied
                ? OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      side: const BorderSide(color: AppTheme.danger),
                      foregroundColor: AppTheme.danger,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.rMd),
                      ),
                    ),
                    child: const Text('Remove'),
                  )
                : FilledButton(
                    onPressed: eligible ? onApply : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor: AppTheme.border,
                      disabledForegroundColor: AppTheme.textMuted,
                    ),
                    child: Text(eligible ? 'Apply' : 'Not eligible yet'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _discountLabel(Voucher v, bool eligible) {
    final color = eligible ? Colors.white : AppTheme.textMuted;

    if (v.freeShipping) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined, size: 20, color: color),
          Text('FREE',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      );
    }
    if (v.discountPercent != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${v.discountPercent!.toInt()}%',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
          Text('OFF',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Rs',
          style: TextStyle(fontSize: 9, color: color),
        ),
        Text(
          '${v.discountRs?.toInt() ?? 0}',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

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
              Icon(Icons.info_outline, size: 16, color: AppTheme.textMuted),
              SizedBox(width: 6),
              Text(
                'How vouchers work',
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
            '• One voucher per order\n'
            '• Applied at checkout or from the bag\n'
            '• Cannot be combined with other vouchers\n'
            '• Eligibility depends on bag value at checkout',
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