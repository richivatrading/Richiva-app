import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/order.dart';
import '../../shared/providers/orders_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/order_widgets.dart';

class TrackOrderScreen extends ConsumerWidget {
  final String id;
  const TrackOrderScreen({super.key, required this.id});

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
      appBar: AppBar(title: Text('Track ${order.id}')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.s16),
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.s16),
              decoration: BoxDecoration(
                color: order.status.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.rLg),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined,
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
                          'Estimated delivery 2–4 business days',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.s24),
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
            if (order.status.nextStep != null && order.status.isActive)
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(ordersProvider.notifier).advanceStatus(order.id);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Simulate next status (demo)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppTheme.border),
                  foregroundColor: AppTheme.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.rMd),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}