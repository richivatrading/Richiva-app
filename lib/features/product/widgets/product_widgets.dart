import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GALLERY — PageView with dots indicator
// ─────────────────────────────────────────────────────────────────────────────
class ProductGallery extends StatefulWidget {
  final List<String> images;
  const ProductGallery({super.key, required this.images});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: widget.images[i],
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppTheme.border),
            errorWidget: (_, __, ___) => Container(
              color: AppTheme.border,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppTheme.textMuted),
            ),
          ),
        ),
        // Dots indicator at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: AppTheme.s16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : AppTheme.border,
                  borderRadius: BorderRadius.circular(AppTheme.rPill),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIZE SELECTOR
// ─────────────────────────────────────────────────────────────────────────────
class SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selected;
  final ValueChanged<String> onSelect;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.s8,
      runSpacing: AppTheme.s8,
      children: sizes.map((s) {
        final active = s == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          onTap: () => onSelect(s),
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.rMd),
              border: Border.all(
                color: active ? AppTheme.primary : AppTheme.border,
              ),
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppTheme.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLOR SELECTOR — swatches
// ─────────────────────────────────────────────────────────────────────────────
class ColorSelector extends StatelessWidget {
  final List<String> colors;
  final String? selected;
  final ValueChanged<String> onSelect;

  const ColorSelector({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  static const _map = {
    'black': Color(0xFF000000),
    'white': Color(0xFFFFFFFF),
    'beige': Color(0xFFD9C9B0),
    'navy': Color(0xFF1E3A5F),
    'red': Color(0xFFDC2626),
    'green': Color(0xFF16A34A),
    'blue': Color(0xFF3B82F6),
    'pink': Color(0xFFF472B6),
    'grey': Color(0xFF9CA3AF),
    'gray': Color(0xFF9CA3AF),
  };

  static Color colorOf(String name) =>
      _map[name.toLowerCase()] ?? const Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.s12,
      runSpacing: AppTheme.s12,
      children: colors.map((c) {
        final active = c == selected;
        final tint = colorOf(c);
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? AppTheme.primary : AppTheme.border,
                    width: active ? 2.5 : 1,
                  ),
                ),
                child: active
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: tint.computeLuminance() > 0.5
                            ? AppTheme.primary
                            : Colors.white,
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                c,
                style: TextStyle(
                  fontSize: 10,
                  color: active ? AppTheme.primary : AppTheme.textMuted,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDABLE DESCRIPTION
// ─────────────────────────────────────────────────────────────────────────────
class ExpandableText extends StatefulWidget {
  final String text;
  final int collapsedLines;
  const ExpandableText({
    super.key,
    required this.text,
    this.collapsedLines = 3,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            widget.text,
            maxLines: widget.collapsedLines,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          secondChild: Text(widget.text,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Read less' : 'Read more',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO TILE — delivery / returns
// ─────────────────────────────────────────────────────────────────────────────
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.s8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(AppTheme.rMd),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: AppTheme.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BARGAIN SHEET
// ─────────────────────────────────────────────────────────────────────────────
class BargainSheet extends StatefulWidget {
  final double originalPrice;
  const BargainSheet({super.key, required this.originalPrice});

  static Future<void> show(BuildContext context, double originalPrice) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BargainSheet(originalPrice: originalPrice),
      ),
    );
  }

  @override
  State<BargainSheet> createState() => _BargainSheetState();
}

class _BargainSheetState extends State<BargainSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.s24),
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
          Text('Make an offer',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppTheme.s8),
          Text(
            'Original price: Rs. ${widget.originalPrice.toStringAsFixed(0)}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: AppTheme.s16),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Your offer (Rs.)',
              prefixText: 'Rs. ',
            ),
          ),
          const SizedBox(height: AppTheme.s16),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(_ctrl.text.trim());
              if (v == null || v <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid amount')),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Offer sent: Rs. ${v.toStringAsFixed(0)}. We\'ll notify you.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Offer'),
          ),
          const SizedBox(height: AppTheme.s8),
        ],
      ),
    );
  }
}