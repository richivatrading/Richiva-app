import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/checkout_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/checkout_widgets.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressProvider);
    final checkout = ref.watch(checkoutProvider);
    final selectedId = checkout.addressId;
    final isDefault = checkout.addressId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Address')),
      body: SafeArea(
        child: Column(
          children: [
            const CheckoutStepper(current: 0),
            const SizedBox(height: AppTheme.s8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.s16),
                children: [
                  if (addresses.isEmpty)
                    const Center(
                      child: Text('No addresses yet. Add one to continue.'),
                    )
                  else
                    ...addresses.map((a) {
                      final sel = a.id == selectedId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.s12),
                        child: AddressCard(
                          address: a,
                          selected: sel,
                          isDefault: sel,
                          onSelect: () => ref.read(checkoutProvider.notifier).setAddress(a.id),
                          onEdit: () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => AddressForm(initial: a),
                          ),
                          onDelete: () {
                            ref.read(addressProvider.notifier).remove(a.id);
                            if (selectedId == a.id) {
                              ref.read(checkoutProvider.notifier).setAddress('');
                            }
                          },
                          onMakeDefault: () {
                            ref.read(checkoutProvider.notifier).setAddress(a.id);
                          },
                        ),
                      );
                    }),
                  const SizedBox(height: AppTheme.s8),
                  OutlinedButton.icon(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => const AddressForm(),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add new address'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            // ── Continue button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.s16),
                child: FilledButton(
                  onPressed: selectedId == null
                      ? null
                      : () => context.push('/checkout/shipping'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Continue to shipping'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}