import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Draggable gallery — wraps the ProductGallery so users can long-press
// then drag the product image to the bag icon.
// ─────────────────────────────────────────────────────────────────────────────
class DraggableProductImage extends StatelessWidget {
  final Widget child;
  final String productId;
  final String imageUrl;

  const DraggableProductImage({
    super.key,
    required this.child,
    required this.productId,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<String>(
      data: productId,
      delay: const Duration(milliseconds: 250),
      feedback: _DragFeedback(imageUrl: imageUrl),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: child,
      ),
      child: Stack(
        children: [
          child,
          const Positioned(
            bottom: 16,
            left: 16,
            child: DragHintPill(),
          ),
        ],
      ),
      onDragStarted: () => HapticFeedback.mediumImpact(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drop target — wraps the bag icon in the app bar
// ─────────────────────────────────────────────────────────────────────────────
class BagDropTarget extends StatelessWidget {
  final Widget child;
  final void Function(String productId) onDrop;

  const BagDropTarget({
    super.key,
    required this.child,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data.isNotEmpty,
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return AnimatedScale(
          scale: hovering ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hovering
                  ? AppTheme.success.withValues(alpha: 0.2)
                  : Colors.transparent,
              boxShadow: hovering
                  ? [
                      BoxShadow(
                        color: AppTheme.success.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drag feedback — the thumbnail that follows the cursor
// ─────────────────────────────────────────────────────────────────────────────
class _DragFeedback extends StatelessWidget {
  final String imageUrl;
  const _DragFeedback({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 0.4,
        child: Container(
          width: 280,
          height: 380,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
            image: DecorationImage(
              image: CachedNetworkImageProvider(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Hold & drag" hint pill — bottom-left of the gallery
// ─────────────────────────────────────────────────────────────────────────────
class DragHintPill extends StatelessWidget {
  const DragHintPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.touch_app_outlined,
              size: 12, color: Colors.white70),
          SizedBox(width: 4),
          Text(
            'Hold & drag to bag',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}