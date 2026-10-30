import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/orders_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/order_widgets.dart';

class ReturnScreen extends ConsumerStatefulWidget {
  final String id;
  const ReturnScreen({super.key, required this.id});

  @override
  ConsumerState<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends ConsumerState<ReturnScreen> {
  final Set<int> _selected = {};
  String _type = 'return';
  String? _reason;
  String? _exchangeSize;

  static const _reasons = [
    'Wrong size / doesn\'t fit',
    'Defective / damaged',
    'Not as described',
    'Wrong item received',
    'Changed my mind',
  ];

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  void _submit() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one item')),
      );
      return;
    }
    if (_reason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a reason')),
      );
      return;
    }
    if (_type == 'exchange' && _exchangeSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a new size')),
      );
      return;
    }

    ref.read(ordersProvider.notifier).requestReturn(
          orderId: widget.id,
          itemIndexes: _selected.toList(),
          type: _type,
          reason: _reason!,
          exchangeSize: _exchangeSize,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _type == 'exchange'
              ? 'Exchange requested. We\'ll pick up and ship the new size.'
              : 'Return requested. We\'ll schedule a pickup.',
        ),
      ),
    );
    context.go('/returns');
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
      appBar: AppBar(title: const Text('Return / Exchange')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.s16),
          children: [
            const _SectionTitle('Select items'),
            ...order.items.asMap().entries.map((e) {
              final selected = _selected.contains(e.key);
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.s8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.rMd),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: selected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selected.add(e.key);
                      } else {
                        _selected.remove(e.key);
                      }
                    });
                  },
                  activeColor: AppTheme.primary,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  title: OrderItemRow(item: e.value),
                ),
              );
            }),
            const SizedBox(height: AppTheme.s16),
            const _SectionTitle('Type'),
            Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    label: 'Return',
                    selected: _type == 'return',
                    onTap: () => setState(() => _type = 'return'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeChip(
                    label: 'Exchange',
                    selected: _type == 'exchange',
                    onTap: () => setState(() => _type = 'exchange'),
                  ),
                ),
              ],
            ),
            if (_type == 'exchange') ...[
              const SizedBox(height: AppTheme.s16),
              const _SectionTitle('New size'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sizes.map((s) {
                  final active = _exchangeSize == s;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.rMd),
                    onTap: () => setState(() => _exchangeSize = s),
                    child: Container(
                      constraints: const BoxConstraints(
                          minWidth: 48, minHeight: 44),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.rMd),
                        border: Border.all(
                          color:
                              active ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              active ? Colors.white : AppTheme.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: AppTheme.s16),
            const _SectionTitle('Reason'),
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
            const SizedBox(height: AppTheme.s24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s12),
          child: FilledButton(
            onPressed: _submit,
            child: Text(_type == 'exchange'
                ? 'Submit exchange request'
                : 'Submit return request'),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.s8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
                letterSpacing: 0.3)),
      );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}