import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/orders_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/order_widgets.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            labelColor: AppTheme.primary,
            indicatorColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(
              orders: ref.watch(activeOrdersProvider),
              emptyMessage: 'No active orders',
            ),
            _OrderList(
              orders: ref.watch(deliveredOrdersProvider),
              emptyMessage: 'No delivered orders yet',
            ),
            _OrderList(
              orders: ref.watch(cancelledOrdersProvider),
              emptyMessage: 'No cancelled orders',
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<dynamic> orders;
  final String emptyMessage;
  const _OrderList({required this.orders, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyOrders(
        message: emptyMessage,
        ctaLabel: 'Start shopping',
        onCta: () => context.go('/'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.s16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.s12),
      itemBuilder: (_, i) => OrderCard(order: orders[i]),
    );
  }
}