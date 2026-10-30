import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/bag_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/bag_widgets.dart';

class BagScreen extends ConsumerWidget {
  const BagScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(bagProvider);
    final itemCount = items.fold<int>(0, (s, x) => s + x.quantity);
    final total = ref.watch(bagTotalProvider);

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bag')),
        body: EmptyBag(onShop: () => context.go('/')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bag ($itemCount)'),
        actions: [
          TextButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear bag?'),
                  content:
                      const Text('Remove all items from your bag?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(bagProvider.notifier).clear();
                        ref.read(voucherProvider.notifier).remove();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear',
                          style: TextStyle(color: AppTheme.danger)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Clear'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.s16, AppTheme.s16, AppTheme.s16, AppTheme.s16,
          ),
          children: [
            // ── Items
            ...items.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.s12),
                child: BagItemCard(item: entry.value, index: entry.key),
              );
            }),

            const SizedBox(height: AppTheme.s8),

            // ── Voucher
            const VoucherInput(),

            const SizedBox(height: AppTheme.s16),

            // ── Summary
            const OrderSummary(),

            const SizedBox(height: AppTheme.s8),
          ],
        ),
      ),

      // ── Sticky CTA
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.s12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.5),
                  ),
                  Text(
                    'Rs. ${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.push('/checkout/address'),
                  child: Text('Checkout ($itemCount)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}