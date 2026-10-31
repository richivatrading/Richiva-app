import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bag_provider.dart';

import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────
// FullPageLoader – shown while data is loading
// ─────────────────────────────────────────────────────────────────────
class FullPageLoader extends StatelessWidget {
  const FullPageLoader({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────
// FullScreenError – shown when an error occurs
// ─────────────────────────────────────────────────────────────────────
class FullScreenError extends StatelessWidget {
  final Object error;
  final StackTrace? stack;
  final String message;
  final VoidCallback? onRetry;

  FullScreenError({
    super.key,
    required this.error,
    this.stack,
    this.message = 'An error occurred',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(message, style: Theme.of(context).textTheme.titleLarge),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          FilledButton(
          onPressed: onRetry, child: const Text('Retry')),
        ],
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────
// GenericEmptyState – shown when a list is empty
// ─────────────────────────────────────────────────────────────────────
class GenericEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onCTA;
  final String ctaLabel;

  GenericEmptyState({
    super.key,
    required this.message,
    this.onCTA,
    this.ctaLabel = 'Go back',
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, size: 64, color: AppTheme.textMuted),
        const SizedBox(height: 16),
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
        if (onCTA != null) ...[
          const SizedBox(height: 24),
          OutlinedButton(
          onPressed: onCTA, child: Text(ctaLabel)),
        ],
      ],
    ),
  );
}