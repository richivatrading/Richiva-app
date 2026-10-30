import 'package:flutter/material.dart';

class CustomGarmentScreen extends StatefulWidget {
  const CustomGarmentScreen({super.key});

  @override
  State<CustomGarmentScreen> createState() => _CustomGarmentScreenState();
}

class _CustomGarmentScreenState extends State<CustomGarmentScreen> {
  final PageController _pageCtrl = PageController();
  int _step = 0;
  static const int _totalSteps = 7;

  String? _garment;
  String? _fabric;
  String? _color;
  final _bust = TextEditingController();
  final _waist = TextEditingController();
  final _hips = TextEditingController();
  final _shoulder = TextEditingController();
  final _height = TextEditingController();
  bool _addLining = false;
  final _styleNotes = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();

  // ── Price tables ─────────────────────────────────────────────────────────
  static const Map<String, int> _garmentBasePrices = {
    'Dress': 4500,
    'Shirt': 2800,
    'Trousers': 3200,
    'Jacket': 6500,
    'Skirt': 2500,
    'Blouse': 3000,
    'Suit': 12000,
  };

  static const Map<String, double> _fabricMultipliers = {
    'Cotton': 1.0,
    'Silk': 1.4,
    'Linen': 0.9,
    'Wool': 1.6,
    'Cotton-silk blend': 1.2,
  };

  static const int _liningSurcharge = 800;

  // ── Estimate ─────────────────────────────────────────────────────────────
  ({int low, int high, int midpoint, int base, int lining})? _calculateEstimate() {
    if (_garment == null || _fabric == null) return null;
    final base = _garmentBasePrices[_garment] ?? 0;
    final mult = _fabricMultipliers[_fabric] ?? 1.0;
    final lining = _addLining ? _liningSurcharge : 0;
    final midpoint = (base * mult + lining).round();
    final low = ((midpoint * 0.85) / 100).floor() * 100;
    final high = ((midpoint * 1.15) / 100).ceil() * 100;
    return (
      low: low,
      high: high,
      midpoint: midpoint,
      base: base,
      lining: lining,
    );
  }

  // ── Jump to a specific step (used by editable review rows) ───────────────
  void _jumpToStep(int step) {
    if (step < 0 || step >= _totalSteps) return;
    setState(() => _step = step);
    _pageCtrl.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _hintForStep(int step) {
    switch (step) {
      case 0:
        return 'Select the type of garment you want';
      case 1:
        return 'Choose your fabric';
      case 2:
        return 'Pick a color';
      case 3:
        return 'Enter your measurements in inches';
      case 4:
        return 'Add lining and style preferences';
      case 5:
        return 'Where should we deliver?';
      case 6:
        return 'Review and submit';
      default:
        return '';
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Garment'),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _jumpToStep(_step - 1),
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            height: 4,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _totalSteps,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= _step ? Colors.amber : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // PageView
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGarmentStep(),
                _buildFabricStep(),
                _buildColorStep(),
                _buildMeasurementsStep(),
                _buildStyleStep(),
                _buildContactStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          // Bottom navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _jumpToStep(_step - 1),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _step == _totalSteps - 1 ? _submit : () => _jumpToStep(_step + 1),
                    child: Text(_step == _totalSteps - 1 ? 'Submit request' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step builders ────────────────────────────────────────────────────────
  Widget _buildGarmentStep() => _StepBody(
    title: 'What garment?',
    subtitle: 'Select the type of garment you want tailored.',
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _garmentBasePrices.keys.map((g) => _ChoiceChip(
        label: g,
        selected: _garment == g,
        onTap: () => setState(() => _garment = g),
      )).toList(),
    ),
  );

  Widget _buildFabricStep() => _StepBody(
    title: 'Choose fabric',
    subtitle: 'Pick your fabric. Each has a different price multiplier.',
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _fabricMultipliers.keys.map((f) => _ChoiceChip(
        label: f,
        selected: _fabric == f,
        onTap: () => setState(() => _fabric = f),
      )).toList(),
    ),
  );

  Widget _buildColorStep() => _StepBody(
    title: 'Select color',
    subtitle: 'Choose a color for your garment.',
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ['Navy', 'Black', 'White', 'Beige', 'Grey', 'Olive', 'Burgundy', 'Charcoal']
          .map((c) => _ChoiceChip(
                label: c,
                selected: _color == c,
                onTap: () => setState(() => _color = c),
              ))
          .toList(),
    ),
  );

  Widget _buildMeasurementsStep() => _StepBody(
    title: 'Your measurements',
    subtitle: 'Enter all measurements in inches.',
    child: Column(
      children: [
        _MeasurementField(label: 'Bust', controller: _bust),
        _MeasurementField(label: 'Waist', controller: _waist),
        _MeasurementField(label: 'Hips', controller: _hips),
        _MeasurementField(label: 'Shoulder', controller: _shoulder),
        _MeasurementField(label: 'Height', controller: _height),
      ],
    ),
  );

  Widget _buildStyleStep() => _StepBody(
    title: 'Style options',
    subtitle: 'Add lining and any special requests.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Full lining (+Rs. 800)'),
          value: _addLining,
          onChanged: (v) => setState(() => _addLining = v ?? false),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _styleNotes,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Style notes (optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    ),
  );

  Widget _buildContactStep() => _StepBody(
    title: 'Contact & delivery',
    subtitle: 'Where should we reach you and deliver the garment?',
    child: Column(
      children: [
        TextField(
          controller: _phone,
          decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _address,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Delivery address', border: OutlineInputBorder()),
        ),
      ],
    ),
  );

  Widget _buildReviewStep() {
    final estimate = _calculateEstimate();
    return _StepBody(
      title: 'Review your request',
      subtitle: 'Once submitted, our tailoring team will reach out within 24 hours with a final quote.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Estimate card
          if (estimate != null)
            _EstimateCard(
              low: estimate.low,
              high: estimate.high,
              midpoint: estimate.midpoint,
              base: estimate.base,
              lining: estimate.lining,
              garmentName: _garment ?? '',
              fabricName: _fabric ?? '',
              fabricMult: _fabricMultipliers[_fabric ?? ''] ?? 1.0,
              onAdjust: () => _jumpToStep(0),
            ),

          const SizedBox(height: 16),

          // ── Editable review rows
          _ReviewRow(
            label: 'Garment',
            value: _garment ?? '—',
            onTap: () => _jumpToStep(0),
          ),
          _ReviewRow(
            label: 'Fabric',
            value: _fabric ?? '—',
            onTap: () => _jumpToStep(1),
          ),
          _ReviewRow(
            label: 'Color',
            value: _color ?? '—',
            onTap: () => _jumpToStep(2),
          ),
          _ReviewRow(
            label: 'Bust',
            value: _bust.text.isEmpty ? '—' : '${_bust.text}"',
            onTap: () => _jumpToStep(3),
          ),
          _ReviewRow(
            label: 'Waist',
            value: _waist.text.isEmpty ? '—' : '${_waist.text}"',
            onTap: () => _jumpToStep(3),
          ),
          _ReviewRow(
            label: 'Hips',
            value: _hips.text.isEmpty ? '—' : '${_hips.text}"',
            onTap: () => _jumpToStep(3),
          ),
          _ReviewRow(
            label: 'Shoulder',
            value: _shoulder.text.isEmpty ? '—' : '${_shoulder.text}"',
            onTap: () => _jumpToStep(3),
          ),
          _ReviewRow(
            label: 'Height',
            value: _height.text.isEmpty ? '—' : '${_height.text}"',
            onTap: () => _jumpToStep(3),
          ),
          _ReviewRow(
            label: 'Lining',
            value: _addLining ? 'Yes' : 'No',
            onTap: () => _jumpToStep(4),
          ),
          if (_styleNotes.text.trim().isNotEmpty)
            _ReviewRow(
              label: 'Style notes',
              value: _styleNotes.text.trim(),
              multiline: true,
              onTap: () => _jumpToStep(4),
            ),
          const Divider(height: 32),
          _ReviewRow(
            label: 'Phone',
            value: _phone.text,
            onTap: () => _jumpToStep(5),
          ),
          _ReviewRow(
            label: 'Email',
            value: _email.text,
            onTap: () => _jumpToStep(5),
          ),
          _ReviewRow(
            label: 'Address',
            value: _address.text,
            multiline: true,
            onTap: () => _jumpToStep(5),
          ),
        ],
      ),
    );
  }

  void _submit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request submitted'),
        content: const Text('Your custom garment request has been received. Reference: CG-${DateTime.now().millisecondsSinceEpoch}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bust.dispose();
    _waist.dispose();
    _hips.dispose();
    _shoulder.dispose();
    _height.dispose();
    _styleNotes.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _StepBody extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepBody({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.amber : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.amber : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _MeasurementField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _MeasurementField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixText: '"',
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;
  final VoidCallback? onTap;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.multiline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final body = multiline
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_outlined, size: 10, color: Colors.grey),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (onTap != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.edit_outlined, size: 12, color: Colors.grey),
                  ),
              ],
            ),
          );

    if (onTap == null) return body;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: body,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estimate card
// ─────────────────────────────────────────────────────────────────────────────
class _EstimateCard extends StatelessWidget {
  final int low;
  final int high;
  final int midpoint;
  final int base;
  final int lining;
  final String garmentName;
  final String fabricName;
  final double fabricMult;
  final VoidCallback onAdjust;

  const _EstimateCard({
    required this.low,
    required this.high,
    required this.midpoint,
    required this.base,
    required this.lining,
    required this.garmentName,
    required this.fabricName,
    required this.fabricMult,
    required this.onAdjust,
  });

  String _fmt(num v) {
    final s = v.round().toString();
    return s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calculate_outlined, size: 18, color: Colors.amber),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Estimated price',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: onAdjust,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text('Adjust →', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rs. ${_fmt(low)} – Rs. ${_fmt(high)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Final quote confirmed within 24 hours',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 8),
          _EstimateLine(
            label: 'Base ($garmentName)',
            value: 'Rs. ${_fmt(base)}',
          ),
          _EstimateLine(
            label: '× $fabricName (${fabricMult.toStringAsFixed(1)}×)',
            value: 'Rs. ${_fmt(base * fabricMult)}',
          ),
          if (lining > 0)
            _EstimateLine(
              label: '+ Full lining',
              value: 'Rs. ${_fmt(lining)}',
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 1, color: Colors.grey),
          ),
          _EstimateLine(
            label: 'Midpoint estimate',
            value: 'Rs. ${_fmt(midpoint)}',
            bold: true,
          ),
          const SizedBox(height: 8),
          const Text(
            'Final price may vary based on fabric availability and tailoring complexity.',
            style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _EstimateLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _EstimateLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 13 : 12,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 13 : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}