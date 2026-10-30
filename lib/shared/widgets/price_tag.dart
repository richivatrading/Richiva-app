import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final double? comparePrice;
  final double fontSize;

  const PriceTag({
    super.key,
    required this.price,
    this.comparePrice,
    this.fontSize = 14,
  });

  String _fmt(double n) {
    final s = n.toStringAsFixed(0);
    // Add thousands separators: 12345 -> 12,345
    return s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Rs. ${_fmt(price)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
        if (comparePrice != null) ...[
          const SizedBox(width: 6),
          Text(
            'Rs. ${_fmt(comparePrice!)}',
            style: TextStyle(
              fontSize: fontSize - 2,
              color: AppTheme.textMuted,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}