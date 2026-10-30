import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/order.dart';
import '../../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Status pill
// ─────────────────────────────────────────────────────────────────────────────
class StatusPill extends StatelessWidget {
  final OrderStatus status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.rPill),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order card (used in Orders list)
// ─────────────────────────────────────────────────────────────────────────────
class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rLg),
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.rLg),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppTheme.primary,
                  ),
                ),
                const Spacer(),
                StatusPill(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _dateLabel(order.createdAt),
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.s12),
            SizedBox(
              height: 72,
              child: Row(
                children: [
                  ...order.items.take(3).toList().asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.rMd),
                        child: SizedBox(
                          width: 60,
                          height: 72,
                          child: CachedNetworkImage(
                            imageUrl: e.value.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Container(color: AppTheme.border),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (order.items.length > 3)
                    Container(
                      width: 60,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(AppTheme.rMd),
                      ),
                      child: Text(
                        '+${order.items.length - 3}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textMuted),
                      ),
                      Text(
                        'Rs. ${order.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.s12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    label: _primaryActionLabel(order.status),
                    onTap: () => _primaryAction(context, order),
                  ),
                ),
                const SizedBox(width: AppTheme.s8),
                Expanded(
                  child: _QuickAction(
                    label: 'Details',
                    secondary: true,
                    onTap: () => context.push('/orders/${order.id}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _primaryActionLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.toPay:     return 'Pay now';
      case OrderStatus.toShip:    return 'Cancel';
      case OrderStatus.toReceive: return 'Track';
      case OrderStatus.toReview:  return 'Review';
      case OrderStatus.delivered: return 'Buy again';
      default:                    return 'View';
    }
  }

  void _primaryAction(BuildContext context, Order order) {
    switch (order.status) {
      case OrderStatus.toPay:
        context.push('/order/${order.id}/result');
        break;
      case OrderStatus.toShip:
        context.push('/orders/${order.id}/cancel');
        break;
      case OrderStatus.toReceive:
        context.push('/orders/${order.id}/track');
        break;
      case OrderStatus.toReview:
        context.push('/product/${order.items.first.productId}/reviews');
        break;
      case OrderStatus.delivered:
        context.push('/product/${order.items.first.productId}');
        break;
      default:
        context.push('/orders/${order.id}');
    }
  }

  String _dateLabel(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool secondary;
  const _QuickAction({
    required this.label,
    required this.onTap,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: secondary ? AppTheme.border : AppTheme.primary,
          ),
          foregroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.rMd),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order timeline (used in Track Order + Order Detail)
// ─────────────────────────────────────────────────────────────────────────────
class OrderTimeline extends StatelessWidget {
  final List<TrackingEvent> events;
  const OrderTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final isLast = i == events.length - 1;
        final isDone = e.isDone;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppTheme.success
                            : Colors.white,
                        border: Border.all(
                          color: isDone ? AppTheme.success : AppTheme.border,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check,
                              size: 11, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isDone
                              ? AppTheme.success
                              : AppTheme.border,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? AppTheme.primary
                              : AppTheme.textMuted,
                        ),
                      ),
                      if (e.description != null)
                        Text(
                          e.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      if (e.timestamp != null)
                        Text(
                          _fmt(e.timestamp!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Order item row (used in Order Detail)
// ─────────────────────────────────────────────────────────────────────────────
class OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const OrderItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.rMd),
            child: SizedBox(
              width: 64,
              height: 80,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: AppTheme.border),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Size ${item.size} · ${item.color}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Rs. ${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '× ${item.quantity}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textMuted),
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
// Totals card
// ─────────────────────────────────────────────────────────────────────────────
class OrderTotalsCard extends StatelessWidget {
  final Order order;
  const OrderTotalsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
                      color: color ?? AppTheme.primary)),
            ],
          ),
        );

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
          row('Subtotal', 'Rs. ${order.subtotal.toStringAsFixed(0)}'),
          row(
            'Shipping',
            order.shippingFee == 0
                ? 'Free'
                : 'Rs. ${order.shippingFee.toStringAsFixed(0)}',
            color: order.shippingFee == 0 ? AppTheme.success : null,
          ),
          if (order.discount > 0)
            row(
              'Discount${order.voucherCode != null ? ' (${order.voucherCode})' : ''}',
              '- Rs. ${order.discount.toStringAsFixed(0)}',
              color: AppTheme.success,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paid amount',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Text(
                'Rs. ${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class EmptyOrders extends StatelessWidget {
  final String message;
  final String ctaLabel;
  final VoidCallback onCta;
  const EmptyOrders({
    super.key,
    required this.message,
    required this.ctaLabel,
    required this.onCta,
  });

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
              child: const Icon(Icons.receipt_long_outlined,
                  size: 40, color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.s24),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppTheme.s24),
            FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 48)),
              child: Text(ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}