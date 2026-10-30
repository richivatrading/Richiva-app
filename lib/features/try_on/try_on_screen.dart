import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/try_on_provider.dart';
import '../../theme/app_theme.dart';

class TryOnScreen extends ConsumerStatefulWidget {
  /// Product name passed via `?productName=` when arriving from a
  /// product page. Used for fuzzy garment matching.
  final String? initialProductName;

  const TryOnScreen({super.key, this.initialProductName});

  @override
  ConsumerState<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends ConsumerState<TryOnScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_initialized) return;
      _initialized = true;

      await ref.read(tryOnProvider.notifier).initialize();

      // Fuzzy-match a garment from the opened-from product name.
      final name = widget.initialProductName;
      if (name != null && name.isNotEmpty && mounted) {
        final matched = _matchGarment(name);
        if (matched != null) {
          ref.read(tryOnProvider.notifier).selectGarment(matched);
        }
      }
    });
  }

  /// Best-effort name → garment match. Returns null when no sensible
  /// mapping exists — caller keeps the default garment.
  TryOnGarment? _matchGarment(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dress') || lower.contains('gown')) {
      return TryOnGarment.summerDress;
    }
    if (lower.contains('sweater') ||
        lower.contains('cashmere') ||
        lower.contains('knit')) {
      return TryOnGarment.cashmereSweater;
    }
    if (lower.contains('jeans') ||
        lower.contains('trouser') ||
        lower.contains('pant')) {
      return TryOnGarment.wideLegJeans;
    }
    if (lower.contains('blazer') ||
        lower.contains('jacket') ||
        lower.contains('coat')) {
      return TryOnGarment.oversizedBlazer;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tryOnProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Try On', style: TextStyle(color: Colors.white)),
      ),
      body: state.isCameraActive
          ? _buildCameraPreview(context)
          : _buildCameraError(context, state.cameraError ?? 'Could not start camera'),
      bottomNavigationBar: _buildGarmentSelector(context, ref, state),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Placeholder for camera preview
        Container(color: Colors.black),
        // Garment overlay would go here
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                'Camera Preview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AR try-on rendering goes here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              error,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'On Chrome, camera access may be blocked.\nOn a real device, the camera would start here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(tryOnProvider.notifier).setCameraActive(true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Camera'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGarmentSelector(
      BuildContext context, WidgetRef ref, TryOnState state) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.s12,
        horizontal: AppTheme.s16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Garment',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: TryOnGarment.values.map((garment) {
                final isSelected = state.selectedGarment == garment;
                return GestureDetector(
                  onTap: () => ref.read(tryOnProvider.notifier).selectGarment(garment),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.rMd),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.rMd),
                            child: Image.network(
                              garment.imageUrl,
                              fit: BoxFit.cover,
                              width: 70,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.white30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          garment.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}