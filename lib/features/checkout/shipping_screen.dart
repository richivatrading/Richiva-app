import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/checkout.dart';
import '../../shared/providers/checkout_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/checkout_widgets.dart';

class ShippingScreen extends ConsumerWidget {
  const ShippingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);
    final selectedId = checkout.shippingId;
    final hasAddress = checkout.addressId != null;

    // Redirect if no address selected
    if (!hasAddress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/checkout/address');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Method')),
      body: SafeArea(
        child: Column(
          children: [
            const CheckoutStepper(current: 1),
            const SizedBox(height: AppTheme.s8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.s16),
                children: [
                  ...kShippingMethods.map((m) {
                    final sel = m.id == selectedId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.s12),
                      child: ShippingMethodCard(
                        method: m,
                        selected: sel,
                        onSelect: () => ref.read(checkoutProvider.notifier).setShipping(m.id),
                      ),
                    );
                  }),
                  const SizedBox(height: AppTheme.s16),
                  const Text(
                    'Fees and timings are sample values. Vouchers may reduce delivery fees.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.s16),
                child: FilledButton(
                  onPressed: selectedId == null
                      ? null
                      : () => context.push('/checkout/payment'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Continue to payment'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}