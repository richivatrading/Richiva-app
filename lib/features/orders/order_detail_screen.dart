import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/order.dart';
import '../../shared/providers/orders_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/order_widgets.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String id;
  const OrderDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(id));

    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(order.id),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () => context.push('/support'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.s16),
          children: [
            // Status header
            Container(
              padding: const EdgeInsets.all(AppTheme.s16),
              decoration: BoxDecoration(
                color: order.status.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.rLg),
              ),
              child: Row(
                children: [
                  Icon(_iconFor(order.status),
                      color: order.status.color, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.status.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: order.status.color,
                          ),
                        ),
                        Text(
                          _subtitleFor(order),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.s16),

            // Timeline (if active or just delivered)
            if (!order.status.isCancelled &&
                !order.status.isDelivered) ...[
              const _SectionTitle('Tracking'),
              Container(
                padding: const EdgeInsets.all(AppTheme.s16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.rMd),
                  border: Border.all(color: AppTheme.border),
                ),
                child: OrderTimeline(events: order.timeline),
              ),
              const SizedBox(height: AppTheme.s16),
            ],

            // Items
            const _SectionTitle('Items'),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.s16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.rMd),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children:
                    order.items.map((i) => OrderItemRow(item: i)).toList(),
              ),
            ),

            const SizedBox(height: AppTheme.s16),

            // Totals
            OrderTotalsCard(order: order),

            const SizedBox(height: AppTheme.s16),

            // Delivery
            const _SectionTitle('Delivery address'),
            Container(
              padding: const EdgeInsets.all(AppTheme.s16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.rMd),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.address.label} · ${order.address.name}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.address.oneLine,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                  ),
                  Text(
                    order.address.phone,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.s16),

            // Payment
            const _SectionTitle('Payment'),
            Container(
              padding: const EdgeInsets.all(AppTheme.s16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.rMd),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      size: 20, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_paymentLabel(order.paymentMethod),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        Text(
                          _paymentStatusLabel(order.paymentStatus),
                          style: TextStyle(
                              fontSize: 12,
                              color: order.paymentStatus == PaymentStatus.paid
                                  ? AppTheme.success
                                  : AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Cancel reason
            if (order.cancelReason != null) ...[
              const SizedBox(height: AppTheme.s16),
              const _SectionTitle('Cancellation reason'),
              Container(
                padding: const EdgeInsets.all(AppTheme.s16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.rMd),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(order.cancelReason!,
                    style: const TextStyle(fontSize: 13)),
              ),
            ],

            const SizedBox(height: AppTheme.s24),
          ],
        ),
      ),
      bottomNavigationBar: _ActionBar(order: order),
    );
  }

  IconData _iconFor(OrderStatus s) {
    switch (s) {
      case OrderStatus.toPay:     return Icons.payment;
      case OrderStatus.toShip:    return Icons.inventory_2_outlined;
      case OrderStatus.toReceive: return Icons.local_shipping_outlined;
      case OrderStatus.toReview:  return Icons.rate_review_outlined;
      case OrderStatus.delivered: return Icons.check_circle_outline;
      case OrderStatus.cancelled: return Icons.cancel_outlined;
      case OrderStatus.returned:  return Icons.assignment_return_outlined;
      case OrderStatus.refunded:  return Icons.currency_exchange;
    }
  }

  String _subtitleFor(Order order) {
    switch (order.status) {
      case OrderStatus.toPay:
        return 'Complete payment to confirm your order';
      case OrderStatus.toShip:
        return 'Preparing your items for shipment';
      case OrderStatus.toReceive:
        return 'Your order is on the way';
      case OrderStatus.toReview:
        return 'Delivered — share your review';
      case OrderStatus.delivered:
        return 'Delivered successfully';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
      case OrderStatus.returned:
        return 'Return request submitted';
      case OrderStatus.refunded:
        return 'Amount will be refunded within 5–7 days';
    }
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'cod':    return 'Cash on delivery';
      case 'esewa':  return 'eSewa';
      case 'khalti': return 'Khalti';
      case 'card':   return 'Card';
      default:       return method;
    }
  }

  String _paymentStatusLabel(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.pending:  return 'Payment pending';
      case PaymentStatus.paid:     return 'Paid';
      case PaymentStatus.failed:   return 'Payment failed';
      case PaymentStatus.refunded: return 'Refunded';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.s8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
            letterSpacing: 0.3,
          ),
        ),
      );
}

class _ActionBar extends StatelessWidget {
  final Order order;
  const _ActionBar({required this.order});

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    switch (order.status) {
      case OrderStatus.toPay:
        actions.add(_btn(context, 'Pay now',
            () => context.push('/order/${order.id}/result')));
        actions.add(_btn(context, 'Cancel', secondary: true,
            () => context.push('/orders/${order.id}/cancel')));
        break;
      case OrderStatus.toShip:
        actions.add(_btn(context, 'Cancel order', secondary: true,
            () => context.push('/orders/${order.id}/cancel')));
        break;
      case OrderStatus.toReceive:
        actions.add(_btn(context, 'Track order',
            () => context.push('/orders/${order.id}/track')));
        break;
      case OrderStatus.toReview:
        actions.add(_btn(context, 'Write review',
            () => context.push('/product/${order.items.first.productId}/reviews')));
        break;
      case OrderStatus.delivered:
        actions.add(_btn(context, 'Return / Exchange', secondary: true,
            () => context.push('/orders/${order.id}/return')));
        actions.add(_btn(context, 'Buy again',
            () => context.push('/product/${order.items.first.productId}')));
        break;
      default:
        return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: AppTheme.s8),
              Expanded(child: actions[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String label, VoidCallback onTap,
      {bool secondary = false}) {
    if (secondary) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppTheme.primary),
          foregroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.rMd),
          ),
        ),
        child: Text(label),
      );
    }
    return FilledButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}