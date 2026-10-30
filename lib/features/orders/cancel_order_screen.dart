import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/order.dart';
import '../../shared/providers/orders_provider.dart';
import '../../theme/app_theme.dart';

class CancelOrderScreen extends ConsumerStatefulWidget {
  final String id;
  const CancelOrderScreen({super.key, required this.id});

  @override
  ConsumerState<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends ConsumerState<CancelOrderScreen> {
  String? _reason;
  final _notesCtrl = TextEditingController();

  static const _reasons = [
    'Changed my mind',
    'Ordered by mistake',
    'Found a better price',
    'Delivery time is too long',
    'Need to update address',
    'Other',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_reason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }
    final order = ref.read(orderByIdProvider(widget.id));
    final wasPaid = order?.paymentStatus == PaymentStatus.paid;

    ref.read(ordersProvider.notifier).cancel(widget.id, _reason!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasPaid
              ? 'Order cancelled. Refund will be processed in 5–7 days.'
              : 'Order cancelled.',
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderByIdProvider(widget.id));
    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Cancel ${order.id}')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.s16),
          children: [
            const Text(
              'Why are you cancelling this order?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.s16),
            ..._reasons.map((r) => RadioListTile<String>(
                  value: r,
                  groupValue: _reason,
                  onChanged: (v) => setState(() => _reason = v),
                  title: Text(r,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.primary)),
                  activeColor: AppTheme.primary,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
            const SizedBox(height: AppTheme.s16),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppTheme.s16),
            if (order.paymentStatus == PaymentStatus.paid)
              Container(
                padding: const EdgeInsets.all(AppTheme.s12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.rMd),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: AppTheme.success),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be refunded to your original payment method within 5–7 business days.',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.success),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppTheme.border),
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.rMd),
                    ),
                  ),
                  child: const Text('Keep order'),
                ),
              ),
              const SizedBox(width: AppTheme.s8),
              Expanded(
                child: FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Cancel order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}