import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/checkout.dart';
import '../../../shared/providers/checkout_provider.dart';
import '../../../shared/providers/bag_provider.dart';
import '../../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Step indicator
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutStepper extends StatelessWidget {
  final int current; // 0..3
  const CheckoutStepper({super.key, required this.current});

  static const _titles = ['Address', 'Shipping', 'Payment', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
      child: Row(
        children: List.generate(_titles.length, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 3,
                    color: done || active ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                if (i < _titles.length - 1)
                  const SizedBox(width: AppTheme.s8),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Address card (used in list + selection)
// ─────────────────────────────────────────────────────────────────────────────
class AddressCard extends ConsumerWidget {
  final Address address;
  final bool selected;
  final bool isDefault;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;

  const AddressCard({
    super.key,
    required this.address,
    required this.selected,
    required this.isDefault,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (selected)
                  const Icon(Icons.radio_button_checked,
                      color: AppTheme.primary, size: 20)
                else
                  const Icon(Icons.radio_button_unchecked,
                      color: AppTheme.border, size: 20),
                const SizedBox(width: AppTheme.s8),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      if (isDefault && !selected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(AppTheme.rPill),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.s8),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${address.name}  ·  ${address.phone}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.singleLine,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.s8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 30),
                  ),
                ),
                if (!isDefault) ...[
                  TextButton.icon(
                    onPressed: onMakeDefault,
                    icon: const Icon(Icons.check_circle_outlined, size: 14),
                    label: const Text('Set default'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 30),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 30),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Address form (modal)
// ─────────────────────────────────────────────────────────────────────────────
class AddressForm extends ConsumerStatefulWidget {
  final Address? initial;
  const AddressForm({super.key, this.initial});

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late String _label;
  late String _name;
  late String _phone;
  late String _province;
  late String _city;
  late String _street;
  String? _landmark;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _label = a?.label ?? 'Home';
    _name = a?.name ?? '';
    _phone = a?.phone ?? '';
    _province = a?.province ?? 'Bagmati';
    _city = a?.city ?? '';
    _street = a?.street ?? '';
    _landmark = a?.landmark;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final isEdit = widget.initial != null;
    final address = Address(
      id: widget.initial?.id ?? 'addr-${DateTime.now().millisecondsSinceEpoch}',
      label: _label,
      name: _name.trim(),
      phone: _phone.trim(),
      province: _province,
      city: _city.trim(),
      street: _street.trim(),
      landmark: _landmark?.trim().isNotEmpty == true ? _landmark : null,
    );
    if (isEdit) {
      // For simplicity, remove old and add new
      ref.read(addressProvider.notifier).remove(widget.initial!.id);
    }
    ref.read(addressProvider.notifier).add(address);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Address updated' : 'Address added'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppTheme.s16,
        right: AppTheme.s16,
        top: AppTheme.s16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppTheme.s16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(AppTheme.rPill),
              ),
            ),
            Text(
              widget.initial == null ? 'New address' : 'Edit address',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.s16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Home', label: Text('Home')),
                ButtonSegment(value: 'Work', label: Text('Work')),
                ButtonSegment(value: 'Other', label: Text('Other')),
              ],
              selected: {_label},
              onSelectionChanged: (s) => setState(() => _label = s.first),
            ),
            const SizedBox(height: AppTheme.s12),
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Enter name' : null,
              onSaved: (v) => _name = v ?? '',
            ),
            const SizedBox(height: AppTheme.s12),
            TextFormField(
              initialValue: _phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.length != 10)
                  ? 'Enter 10-digit number'
                  : null,
              onSaved: (v) => _phone = v ?? '',
            ),
            const SizedBox(height: AppTheme.s12),
            DropdownButtonFormField<String>(
              value: _province,
              decoration: const InputDecoration(labelText: 'Province'),
              items: kProvinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _province = v!),
            ),
            const SizedBox(height: AppTheme.s12),
            TextFormField(
              initialValue: _city,
              decoration: const InputDecoration(labelText: 'City'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter city' : null,
              onSaved: (v) => _city = v ?? '',
            ),
            const SizedBox(height: AppTheme.s12),
            TextFormField(
              initialValue: _street,
              decoration: const InputDecoration(labelText: 'Street & area'),
              validator: (v) => (v == null || v.trim().length < 4)
                  ? 'Enter street'
                  : null,
              onSaved: (v) => _street = v ?? '',
            ),
            const SizedBox(height: AppTheme.s12),
            TextFormField(
              initialValue: _landmark,
              decoration: const InputDecoration(
                labelText: 'Landmark (optional)',
              ),
              onSaved: (v) => _landmark = v,
            ),
            const SizedBox(height: AppTheme.s24),
            FilledButton(onPressed: _submit, child: const Text('Save')),
            const SizedBox(height: AppTheme.s16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shipping method card
// ─────────────────────────────────────────────────────────────────────────────
class ShippingMethodCard extends StatelessWidget {
  final ShippingMethod method;
  final bool selected;
  final VoidCallback onSelect;

  const ShippingMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppTheme.primary : AppTheme.border,
              size: 22,
            ),
            const SizedBox(width: AppTheme.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${method.eta}  ·  ${method.note}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              method.fee == 0
                  ? 'Free'
                  : 'Rs. ${method.fee.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment method card
// ─────────────────────────────────────────────────────────────────────────────
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onSelect;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(AppTheme.rMd),
              ),
              child: Icon(method.icon, size: 22, color: AppTheme.primary),
            ),
            const SizedBox(width: AppTheme.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppTheme.primary : AppTheme.border,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order review summary (reuses bag providers)
// ─────────────────────────────────────────────────────────────────────────────
class ReviewOrderSummary extends ConsumerWidget {
  const ReviewOrderSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(bagSubtotalProvider);
    final shipping = ref.watch(bagShippingProvider);
    final discount = ref.watch(bagDiscountProvider);
    final total = ref.watch(bagTotalProvider);
    final voucher = ref.watch(voucherProvider);
    final items = ref.watch(bagProvider);
    final address = ref.watch(selectedAddressProvider);
    final shippingMethod = ref.watch(selectedShippingProvider);
    final paymentMethod = ref.watch(selectedPaymentProvider);

    Widget row(String label, String value, {Color? valueColor, Widget? trailing}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? AppTheme.primary,
                    )),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Items',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary),
          ),
          const SizedBox(height: AppTheme.s8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.rMd),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('${item.size} · ${item.color} · Qty ${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    Text(
                      'Rs. ${(item.price * item.quantity).toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppTheme.s16),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.s12),
          const Text(
            'Order Summary',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary),
          ),
          const SizedBox(height: AppTheme.s8),
          row('Subtotal', 'Rs. ${subtotal.toStringAsFixed(0)}'),
          row(
            'Shipping',
            shipping == 0 ? 'Free' : 'Rs. ${shipping.toStringAsFixed(0)}',
            valueColor: shipping == 0 ? AppTheme.success : null,
          ),
          if (discount > 0)
            row('Discount (${voucher?.code ?? ''})',
                '- Rs. ${discount.toStringAsFixed(0)}',
                valueColor: AppTheme.success),
          const Divider(height: 1, thickness: 1),
          row('Total', 'Rs. ${total.toStringAsFixed(0)}',
              valueColor: AppTheme.primary,
              trailing: const Text('',
                  style: TextStyle(fontWeight: FontWeight.w800))),
          const SizedBox(height: AppTheme.s16),
          if (address != null) ...[
            ReviewSection(title: 'Deliver to', content: address.singleLine),
            const SizedBox(height: AppTheme.s12),
          ],
          if (shippingMethod != null) ...[
            ReviewSection(
                title: 'Shipping', content: '${shippingMethod.name} · ${shippingMethod.eta}'),
            const SizedBox(height: AppTheme.s12),
          ],
          if (paymentMethod != null) ...[
            ReviewSection(
                title: 'Payment',
                content:
                    '${paymentMethod.name} · ${paymentMethod.isOnline ? 'Online' : 'Pay on delivery'}'),
          ],
        ],
      ),
    );
  }
}

class ReviewSection extends StatelessWidget {
  final String title;
  final String content;
  final Widget? action;
  const ReviewSection({super.key, required this.title, required this.content, this.action});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(title,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: AppTheme.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content,
                  style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
              if (action != null) ...[
                const SizedBox(height: 4),
                action!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PrototypeScenarios extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChange;

  const PrototypeScenarios({super.key, required this.current, required this.onChange});

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