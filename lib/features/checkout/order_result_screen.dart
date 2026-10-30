import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/checkout.dart';
import '../../shared/providers/checkout_provider.dart';
import '../../theme/app_theme.dart';

class OrderResultScreen extends ConsumerStatefulWidget {
  final String id;
  const OrderResultScreen({super.key, required this.id});

  @override
  ConsumerState<OrderResultScreen> createState() => _OrderResultScreenState();
}

class _OrderResultScreenState extends ConsumerState<OrderResultScreen> {
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    final scenario = GoRouterState.of(context).extra as Map<String, String>?;
    final paymentStatus = scenario?['scenario'];

    final order = ref.read(ordersProvider).firstWhere(
          (o) => o.id == widget.id,
          orElse: () => Order(
            id: '',
            placedAt: 0,
            status: OrderStatus.placed,
            events: [],
            lines: [],
            address: const Address(
              id: '', label: '', name: '', phone: '', province: '', city: '', street: ''),
            shipping: const OrderShipping(id: '', name: '', fee: 0, eta: ''),
            payment: const OrderPayment(method: '', status: ''),
            totals: const OrderTotals(list: 0, offerSavings: 0, voucherDiscount: 0, shipping: 0, total: 0),
            points: 0,
          ),
        );

    if (order.payment.status == 'pending') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _verify(paymentStatus ?? 'none'));
    }
  }

  Future<void> _verify(String scenario) async {
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    String newStatus;
    switch (scenario) {
      case 'pay-failed':
        newStatus = 'failed';
        break;
      case 'pay-pending':
        newStatus = 'pending';
        break;
      default:
        newStatus = 'paid';
    }

    ref.read(ordersProvider.notifier).updateOrder(widget.id, (o) => Order(
          id: o.id,
          placedAt: o.placedAt,
          status: newStatus == 'paid' ? OrderStatus.confirmed : o.status,
          events: [...o.events, OrderEvent(status: o.status, at: DateTime.now().millisecondsSinceEpoch)],
          lines: o.lines,
          address: o.address,
          shipping: o.shipping,
          payment: OrderPayment(method: o.payment.method, status: newStatus),
          totals: o.totals,
          voucherCode: o.voucherCode,
          points: o.points,
        ));

    setState(() => _verifying = false);
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(ordersProvider).firstWhere(
          (o) => o.id == widget.id,
          orElse: () => Order(
            id: '',
            placedAt: 0,
            status: OrderStatus.placed,
            events: [],
            lines: [],
            address: const Address(
              id: '', label: '', name: '', phone: '', province: '', city: '', street: ''),
            shipping: const OrderShipping(id: '', name: '', fee: 0, eta: ''),
            payment: const OrderPayment(method: '', status: ''),
            totals: const OrderTotals(list: 0, offerSavings: 0, voucherDiscount: 0, shipping: 0, total: 0),
            points: 0,
          ),
        );

    if (order.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Not Found')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppTheme.textMuted),
              const SizedBox(height: AppTheme.s16),
              const Text('Order not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppTheme.s8),
              const Text('We could not find that order on this device.'),
              const SizedBox(height: AppTheme.s24),
              FilledButton(
                onPressed: () => context.go('/orders'),
                child: const Text('View orders'),
              ),
            ],
          ),
        ),
      );
    }

    final ps = order.payment.status;
    final method = kPaymentMethods.firstWhere(
      (p) => p.id == order.payment.method,
      orElse: () => const PaymentMethod(
        id: '', name: '', description: '', icon: Icons.help_outline, isOnline: false),
    );

    Widget header;
    if (_verifying) {
      header = _ResultHeader(
        icon: Icons.hourglass_empty,
        title: 'Verifying your payment',
        subtitle: 'We are confirming with the payment provider. Please keep this screen open.',
        iconColor: AppTheme.primary,
        animate: true,
      );
    } else if (ps == 'failed') {
      header = _ResultHeader(
        icon: Icons.close,
        title: 'Payment failed',
        subtitle: 'No money was taken. Your order is held so you can retry.',
        iconColor: AppTheme.danger,
      );
    } else if (ps == 'pending') {
      header = _ResultHeader(
        icon: Icons.hourglass_empty,
        title: 'Payment pending',
        subtitle: 'The provider has not confirmed yet. We will update this order when it does. Do not pay twice.',
        iconColor: AppTheme.gold,
        animate: true,
      );
    } else {
      header = _ResultHeader(
        icon: Icons.check_circle,
        title: 'Order confirmed',
        subtitle: ps == 'cod-due'
            ? 'Pay the courier when your order arrives.'
            : 'Payment verified (simulated by the prototype server).',
        iconColor: AppTheme.success,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Status')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Column(
            children: [
              header,
              const SizedBox(height: AppTheme.s24),
              Container(
                padding: const EdgeInsets.all(AppTheme.s16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.rMd),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _DetailRow(label: 'Payment', value: '${method.name} · ${ps.toUpperCase()}'),
                    const Divider(height: 1),
                    _DetailRow(label: 'Delivery', value: '${order.shipping.name} · ${order.shipping.eta}'),
                    const Divider(height: 1),
                    _DetailRow(label: 'Deliver to', value: order.address.singleLine),
                    const Divider(height: 1),
                    _DetailRow(label: 'Items', value: '${order.lines.fold<int>(0, (s, x) => s + x.quantity)}'),
                    const Divider(height: 1),
                    _DetailRow(
                      label: 'Total',
                      value: 'Rs. ${order.totals.total.toStringAsFixed(0)}',
                      valueStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.s24),
              if (ps == 'failed' && !_verifying) ...[
                FilledButton(
                  onPressed: () => _verify('none'),
                  child: const Text('Retry payment'),
                ),
                const SizedBox(height: AppTheme.s12),
                OutlinedButton(
                  onPressed: () {
                    ref.read(ordersProvider.notifier).updateOrder(widget.id, (o) => Order(
                          id: o.id,
                          placedAt: o.placedAt,
                          status: o.status,
                          events: o.events,
                          lines: o.lines,
                          address: o.address,
                          shipping: o.shipping,
                          payment: const OrderPayment(method: 'cod', status: 'cod-due'),
                          totals: o.totals,
                          voucherCode: o.voucherCode,
                          points: o.points,
                        ));
                    setState(() {});
                  },
                  child: const Text('Switch to cash on delivery'),
                ),
                const SizedBox(height: AppTheme.s12),
              ],
              if (ps == 'pending' && !_verifying) ...[
                FilledButton(
                  onPressed: () => _verify('none'),
                  child: const Text('Check payment status'),
                ),
                const SizedBox(height: AppTheme.s12),
              ],
              FilledButton(
                onPressed: () => context.go('/orders/${order.id}'),
                child: const Text('View order'),
              ),
              const SizedBox(height: AppTheme.s12),
              OutlinedButton(
                onPressed: () => context.go('/'),
                child: const Text('Continue shopping'),
              ),
              const SizedBox(height: AppTheme.s16),
              const Text(
                'A redirect back from a gateway is not proof of payment. '
                'The server confirms payment before an order is marked paid.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final bool animate;

  const _ResultHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: animate
              ? Icon(icon, size: 64, color: iconColor, key: const ValueKey('spin'))
              : Icon(icon, size: 64, color: iconColor, key: const ValueKey('static')),
        ),
        const SizedBox(height: AppTheme.s16),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.s8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
          child: Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          Text(value, style: valueStyle ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}