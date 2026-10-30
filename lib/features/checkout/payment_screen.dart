import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/checkout.dart';
import '../../shared/providers/checkout_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/checkout_widgets.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);
    final selectedId = checkout.paymentId;
    final hasShipping = checkout.shippingId != null;

    if (!hasShipping) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/checkout/shipping');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Method')),
      body: SafeArea(
        child: Column(
          children: [
            const CheckoutStepper(current: 2),
            const SizedBox(height: AppTheme.s8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.s16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.s12),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.rMd),
                      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.gold, size: 18),
                        const SizedBox(width: AppTheme.s8),
                        Expanded(
                          child: Text(
                            'Which payment methods Richiva offers is still to be confirmed. '
                            'Online options are placeholders until a provider is connected; '
                            'in this prototype you can simulate their outcomes on the review page.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.s16),
                  ...kPaymentMethods.map((m) {
                    final sel = m.id == selectedId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.s12),
                      child: PaymentMethodCard(
                        method: m,
                        selected: sel,
                        onSelect: () => ref.read(checkoutProvider.notifier).setPayment(m.id),
                      ),
                    );
                  }),
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
                      : () => context.push('/checkout/review'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Review order'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}