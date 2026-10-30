import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/order.dart';
import '../../shared/providers/orders_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/order_widgets.dart';

class ReturnsScreen extends ConsumerWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returns = ref.watch(returnsProvider);
    final orders = ref.watch(ordersProvider);

    if (returns.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Returns & Exchanges')),
        body: EmptyOrders(
          message: 'No returns or exchanges yet',
          ctaLabel: 'Browse orders',
          onCta: () => context.push('/orders'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Returns & Exchanges')),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppTheme.s16),
          itemCount: returns.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppTheme.s12),
          itemBuilder: (_, i) {
            final req = returns[i];
            final order =
                orders.firstWhere((o) => o.id == req.orderId);
            return _ReturnCard(request: req, order: order);
          },
        ),
      ),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  final ReturnRequest request;
  final Order order;

  const _ReturnCard({required this.request, required this.order});

  @override
  Widget build(BuildContext context) {
    final typeLabel =
        request.type == 'exchange' ? 'Exchange' : 'Return';
    final accent = request.type == 'exchange'
        ? const Color(0xFF3B82F6)
        : const Color(0xFFF97316);

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rLg),
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.s16),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.rPill),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${request.id.substring(request.id.length - 6)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.s8),
            Text(
              'Order ${order.id} · ${request.itemSummary}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request.reason,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textMuted),
            ),
            if (request.exchangeSize != null) ...[
              const SizedBox(height: 4),
              Text(
                'New size: ${request.exchangeSize}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary),
              ),
            ],
            const SizedBox(height: AppTheme.s8),
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Submitted · ${_date(request.createdAt)}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted),
                ),
                const Spacer(),
                StatusPill(
                  status: request.status == 'approved'
                      ? OrderStatus.refunded
                      : OrderStatus.returned,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';
}