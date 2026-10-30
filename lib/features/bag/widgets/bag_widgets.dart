import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/bag_provider.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../product/widgets/product_widgets.dart';
import '../../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bag item card
// ─────────────────────────────────────────────────────────────────────────────
class BagItemCard extends ConsumerWidget {
  final BagItem item;
  final int index;

  const BagItemCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.rMd),
            child: SizedBox(
              width: 88,
              height: 112,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.border),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.border,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppTheme.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.s12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          ref.read(bagProvider.notifier).removeAt(index),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close,
                            size: 18, color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Size ${item.size}  ·  ${item.color}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.s8),
                Row(
                  children: [
                    QuantityStepper(
                      value: item.quantity,
                      size: 30,
                      onChanged: (q) => ref
                          .read(bagProvider.notifier)
                          .updateQuantity(index, q),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () =>
                          BargainSheet.show(context, item.price * item.quantity),
                      icon: const Icon(Icons.local_offer_outlined, size: 14),
                      label: const Text('Bargain',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Voucher input
// ─────────────────────────────────────────────────────────────────────────────
class VoucherInput extends ConsumerStatefulWidget {
  const VoucherInput({super.key});

  @override
  ConsumerState<VoucherInput> createState() => _VoucherInputState();
}

class _VoucherInputState extends ConsumerState<VoucherInput> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _apply() {
    final subtotal = ref.read(bagSubtotalProvider);
    final catalog = ref.read(voucherCatalogProvider);
    final error =
        ref.read(voucherProvider.notifier).applyCode(_ctrl.text, subtotal, catalog);
    setState(() => _error = error);
    if (error == null) {
      _ctrl.clear();
      FocusScope.of(context).unfocus();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final applied = ref.watch(voucherProvider);

    return Container(
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: applied != null
          ? Row(
              children: [
                const Icon(Icons.local_offer,
                    size: 18, color: AppTheme.success),
                const SizedBox(width: AppTheme.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applied.code,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        applied.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(voucherProvider.notifier).remove(),
                  child: const Text('Remove'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have a voucher?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Enter code',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          errorText: _error,
                        ),
                        onSubmitted: (_) => _apply(),
                      ),
                    ),
                    const SizedBox(width: AppTheme.s8),
                    FilledButton(
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(72, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.s8),
                GestureDetector(
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Available vouchers'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ref.watch(voucherCatalogProvider).values.map((v) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    v.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      v.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    v.minOrderValue > 0
                                        ? 'Min. Rs. ${v.minOrderValue.toStringAsFixed(0)}'
                                        : 'No minimum',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.s8),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(AppTheme.rMd),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Icon(icon, size: 22, color: AppTheme.primary),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.danger,
                          borderRadius:
                              BorderRadius.circular(AppTheme.rPill),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                  fontSize: 11,
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
// Order summary
// ─────────────────────────────────────────────────────────────────────────────
class OrderSummary extends ConsumerWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(bagSubtotalProvider);
    final shipping = ref.watch(bagShippingProvider);
    final discount = ref.watch(bagDiscountProvider);
    final total = ref.watch(bagTotalProvider);
    final voucher = ref.watch(voucherProvider);

    Widget row(String label, String value, {Color? valueColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textMuted)),
            Text(value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppTheme.primary,
                )),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Total',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary)),
          const SizedBox(height: AppTheme.s8),
          row('Subtotal', 'Rs. ${subtotal.toStringAsFixed(0)}'),
          row(
            'Shipping',
            shipping == 0
                ? 'Free'
                : 'Rs. ${shipping.toStringAsFixed(0)}',
            valueColor: shipping == 0 ? AppTheme.success : null,
          ),
          if (discount > 0)
            row(
              'Discount (${voucher?.code ?? ''})',
              '- Rs. ${discount.toStringAsFixed(0)}',
              valueColor: AppTheme.success,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.s8),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
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
          if (voucher == null && subtotal < kFreeShippingThreshold) ...[
            const SizedBox(height: AppTheme.s8),
            Text(
              'Add Rs. ${(kFreeShippingThreshold - subtotal).toStringAsFixed(0)} more for free shipping',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class EmptyBag extends StatelessWidget {
  final VoidCallback onShop;
  const EmptyBag({super.key, required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppTheme.border,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 44, color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.s24),
            Text('Your bag is empty',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppTheme.s8),
            const Text(
              'Add something you love and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.s24),
            FilledButton(
              onPressed: onShop,
              style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 48)),
              child: const Text('Start shopping'),
            ),
          ],
        ),
      ),
    );
  }
}