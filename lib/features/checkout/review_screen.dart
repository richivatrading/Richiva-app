import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/checkout_provider.dart';
import '../../shared/providers/bag_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/checkout_widgets.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  String _scenario = 'none';
  bool _ack = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Ensure bag is not empty
    final items = ref.read(bagProvider);
    if (items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/bag');
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_busy) return;
    final userLoggedIn = true; // TODO: connect to auth
    final items = ref.read(bagProvider);
    if (items.isEmpty || !userLoggedIn) return;

    setState(() => _busy = true);

    // Simulate server delay
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    final orderId = ref.read(ordersProvider.notifier).placeOrder();
    ref.read(checkoutProvider.notifier).reset();

    if (!mounted) return;

    // Navigate to result page with scenario
    context.go('/order/$orderId/result', extra: {'scenario': _scenario});
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);
    final hasAddress = checkout.addressId != null;
    final hasShipping = checkout.shippingId != null;
    final hasPayment = checkout.paymentId != null;

    // Redirect if missing steps
    if (!hasAddress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/checkout/address');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!hasShipping) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/checkout/shipping');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!hasPayment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/checkout/payment');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final address = ref.watch(selectedAddressProvider)!;
    final shippingMethod = ref.watch(selectedShippingProvider)!;
    final paymentMethod = ref.watch(selectedPaymentProvider)!;
    final bagItems = ref.watch(bagProvider);
    final subtotal = ref.watch(bagSubtotalProvider);
    final shipping = ref.watch(bagShippingProvider);
    final discount = ref.watch(bagDiscountProvider);
    final total = ref.watch(bagTotalProvider);
    final voucher = ref.watch(voucherProvider);

    // Scenario handling (prototype)
    final needsAck = (_scenario == 'price' || _scenario == 'stock') && !_ack;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Order')),
      body: SafeArea(
        child: Column(
          children: [
            const CheckoutStepper(current: 3),
            const SizedBox(height: AppTheme.s8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.s16, AppTheme.s8, AppTheme.s16, AppTheme.s8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!true) ...[
                      Container(
                        padding: const EdgeInsets.all(AppTheme.s12),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.rMd),
                          border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.login_outlined, color: AppTheme.danger),
                            const SizedBox(width: AppTheme.s8),
                            Expanded(
                              child: Text(
                                'Sign in to place your order. ',
                                style: TextStyle(color: AppTheme.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.s12),
                    ],

                    // Scenario alerts
                    if (_scenario == 'price' && !_ack) ...[
                      _ScenarioAlert(
                        icon: Icons.warning_amber_rounded,
                        title: 'Price changed',
                        message: 'An item in your bag has a new price. Your total is now Rs. ${total.toStringAsFixed(0)}.',
                        onAccept: () => setState(() => _ack = true),
                      ),
                      const SizedBox(height: AppTheme.s12),
                    ],
                    if (_scenario == 'stock' && !_ack) ...[
                      _ScenarioAlert(
                        icon: Icons.warning_amber_rounded,
                        title: 'Stock changed',
                        message: 'An item has limited stock left. Please update quantity.',
                        onAccept: () => setState(() => _ack = true),
                      ),
                      const SizedBox(height: AppTheme.s12),
                    ],

                    // Items
                    const ReviewOrderSummary(),

                    const SizedBox(height: AppTheme.s16),

                    // Delivery address
                    ReviewSection(
                      title: 'Deliver to',
                      content: '${address.name} · ${address.phone}\n${address.singleLine}',
                      action: TextButton(
                        onPressed: () => context.push('/checkout/address'),
                        child: const Text('Change'),
                      ),
                    ),

                    // Shipping
                    ReviewSection(
                      title: 'Shipping',
                      content: '${shippingMethod.name} · ${shippingMethod.eta}',
                      action: TextButton(
                        onPressed: () => context.push('/checkout/shipping'),
                        child: const Text('Change'),
                      ),
                    ),

                    // Payment
                    ReviewSection(
                      title: 'Payment',
                      content: '${paymentMethod.name} · ${paymentMethod.isOnline ? 'Online payment' : 'Pay on delivery'}',
                      action: TextButton(
                        onPressed: () => context.push('/checkout/payment'),
                        child: const Text('Change'),
                      ),
                    ),

                    const SizedBox(height: AppTheme.s16),

                    // Prototype scenarios
                    PrototypeScenarios(
                      current: _scenario,
                      onChange: (s) => setState(() {
                        _scenario = s;
                        _ack = false;
                      }),
                    ),

                    const SizedBox(height: AppTheme.s8),

                    // Disclaimer
                    Text(
                      'Final order, stock and payment validation happen on the server. '
                      'This prototype places a sample order on this device only; no payment is taken.',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            // ── Place order button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.s16),
                child: FilledButton(
                  onPressed: (_busy || needsAck) ? null : _placeOrder,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Place order · Rs. ${total.toStringAsFixed(0)}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioAlert extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onAccept;

  const _ScenarioAlert({
    required this.icon,
    required this.title,
    required this.message,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.danger),
              const SizedBox(width: AppTheme.s8),
              Text(title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.danger,
                  )),
            ],
          ),
          const SizedBox(height: AppTheme.s8),
          Text(message, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: AppTheme.s12),
          FilledButton(onPressed: onAccept, child: const Text('Accept')),
        ],
      ),
    );
  }
}

class _PrototypeScenarios extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChange;

  const _PrototypeScenarios({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('none', 'Normal'),
      ('price', 'Price change'),
      ('stock', 'Stock change'),
      ('pay-failed', 'Payment fails'),
      ('pay-pending', 'Payment pending'),
    ];

    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      title: const Text('Prototype scenarios (demo only)',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
      children: [
        Wrap(
          spacing: AppTheme.s8,
          runSpacing: AppTheme.s8,
          children: options.map((e) {
            final sel = e.$1 == current;
            return FilterChip(
              label: Text(e.$2),
              selected: sel,
              onSelected: (_) => onChange(e.$1),
              selectedColor: AppTheme.primary.withValues(alpha: 0.1),
              checkmarkColor: AppTheme.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: AppTheme.s8),
        const Text(
          'Payment scenarios apply only to online methods.',
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        const SizedBox(height: AppTheme.s16),
      ],
    );
  }
}