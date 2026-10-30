import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/product.dart';
import '../../shared/providers/bag_provider.dart';
import '../../shared/providers/product_provider.dart';
import '../../shared/providers/reviews_provider.dart';
import '../../shared/widgets/price_tag.dart';
import '../../shared/widgets/quantity_stepper.dart';
import '../../theme/app_theme.dart';
import 'widgets/drag_to_bag.dart';
import 'widgets/product_widgets.dart';

class ProductScreen extends ConsumerStatefulWidget {
  final String id;
  const ProductScreen({super.key, required this.id});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flyController;
  OverlayEntry? _activeFlyEntry;

  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  final _addButtonKey = GlobalKey();
  final _bagIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _activeFlyEntry?.remove();
    _flyController.dispose();
    super.dispose();
  }

  // ── Fly-to-bag animation ─────────────────────────────────────────────────
  Future<void> _flyToBag(Product product) async {
    _activeFlyEntry?.remove();
    _activeFlyEntry = null;

    final sourceBox =
        _addButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final targetBox =
        _bagIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (sourceBox == null || targetBox == null) return;

    final sourceOffset = sourceBox.localToGlobal(Offset.zero);
    final targetOffset = targetBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => AnimatedBuilder(
        animation: _flyController,
        builder: (_, __) {
          final t = Curves.easeInCubic.transform(_flyController.value);
          final offset = Offset.lerp(sourceOffset, targetOffset, t)!;
          final scale = 1 - 0.85 * t;
          return Positioned(
            left: offset.dx,
            top: offset.dy,
            child: IgnorePointer(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        product.galleryImages.first,
                      ),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    _activeFlyEntry = entry;
    overlay.insert(entry);
    _flyController.reset();
    try {
      await _flyController.forward().orCancel;
    } on TickerCanceled {
      // ignore
    } finally {
      _activeFlyEntry?.remove();
      _activeFlyEntry = null;
    }
  }

  void _handleAddToBag(Product product) {
    if (!_validateSelection()) return;
    _addToBag(product);
    _flyToBag(product).then((_) {
      if (!mounted) return;
      _showSuccessSnack(product);
    });
  }

  void _onDropOnBag(String productId, Product product) {
    if (productId != product.id) return;
    if (!_validateSelection()) return;
    _addToBag(product);
    _showSuccessSnack(product);
  }

  bool _validateSelection() {
    if (_selectedSize == null) {
      _prompt('Please select a size');
      return false;
    }
    if (_selectedColor == null) {
      _prompt('Please select a color');
      return false;
    }
    return true;
  }

  void _addToBag(Product product) {
    ref.read(bagProvider.notifier).add(
          BagItem(
            productId: product.id,
            name: product.name,
            imageUrl: product.imageUrl,
            size: _selectedSize!,
            color: _selectedColor!,
            quantity: _quantity,
            price: product.price,
          ),
        );
  }

  void _showSuccessSnack(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity × ${product.name} added to bag'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Bag',
          onPressed: () => context.push('/bag'),
        ),
      ),
    );
  }

  void _prompt(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.id));

    return productAsync.when(
      // 1. LOADING STATE
      loading: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      ),

      // 2. ERROR STATE
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => ref.invalidate(productDetailProvider(widget.id)),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),

      // 3. DATA STATE
      data: (product) {
        final bagCount = ref.watch(bagProvider).fold<int>(0, (s, x) => s + x.quantity);
        final summary = ref.watch(productRatingSummaryProvider(product.id));
        final rating = summary.count > 0 ? summary.average : product.rating;
        final reviewCount = summary.count > 0 ? summary.count : product.reviewCount;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: CustomScrollView(
            slivers: [
              // ── Gallery app bar
              SliverAppBar(
                expandedHeight: 440,
                pinned: true,
                backgroundColor: AppTheme.background,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: _CircleBackButton(),
                actions: [
                  _CircleIconButton(
                    icon: Icons.favorite_border,
                    onTap: () => _prompt('Saved to wishlist'),
                  ),
                  _CircleIconButton(
                    icon: Icons.share_outlined,
                    onTap: () => _prompt('Share coming soon'),
                  ),
                  // Bag icon — fly animation target AND drag drop target
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: BagDropTarget(
                      onDrop: (id) => _onDropOnBag(id, product),
                      child: Container(
                        key: _bagIconKey,
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _CircleIconButton(
                              icon: Icons.shopping_bag_outlined,
                              onTap: () => context.push('/bag'),
                            ),
                            if (bagCount > 0)
                              Positioned(
                                right: 0,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.rPill),
                                  ),
                                  child: Text(
                                    '$bagCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: DraggableProductImage(
                    productId: product.id,
                    imageUrl: product.galleryImages.first,
                    child: ProductGallery(images: product.galleryImages),
                  ),
                ),
              ),

              // ── Content
              SliverToBoxAdapter(
                child: Container(
                  color: AppTheme.background,
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.s16, AppTheme.s16, AppTheme.s16, AppTheme.s32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppTheme.s12),
                      Row(
                        children: [
                          PriceTag(
                            price: product.price,
                            comparePrice: product.comparePrice,
                            fontSize: 22,
                          ),
                          if (product.isOnSale) ...[
                            const SizedBox(width: AppTheme.s8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.danger,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.rPill),
                              ),
                              child: Text(
                                '-${product.discountPercent}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppTheme.s8),
                      InkWell(
                        onTap: () => context.push('/product/${product.id}/reviews'),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: AppTheme.gold),
                            const SizedBox(width: 4),
                            Text(
                              summary.count > 0 ? rating.toStringAsFixed(1) : '${product.rating}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($reviewCount reviews)',
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textMuted),
                            ),
                            const Spacer(),
                            const Text(
                              'See all →',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.s24),
                      const _Label('Size'),
                      const SizedBox(height: AppTheme.s8),
                      SizeSelector(
                        sizes: product.sizes,
                        selected: _selectedSize,
                        onSelect: (s) => setState(() => _selectedSize = s),
                      ),
                      const SizedBox(height: AppTheme.s8),
                      TextButton(
                        onPressed: () => context.push('/size-guide'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Size guide',
                            style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(height: AppTheme.s8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/try-on?productName=${Uri.encodeComponent(product.name)}',
                          ),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text('Try it on with camera'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            side: const BorderSide(color: AppTheme.border),
                            foregroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.rMd),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.s16),
                      const _Label('Color'),
                      const SizedBox(height: AppTheme.s8),
                      ColorSelector(
                        colors: product.colors,
                        selected: _selectedColor,
                        onSelect: (c) => setState(() => _selectedColor = c),
                      ),
                      const SizedBox(height: AppTheme.s24),
                      Row(
                        children: [
                          const _Label('Quantity'),
                          const Spacer(),
                          QuantityStepper(
                            value: _quantity,
                            onChanged: (v) => setState(() => _quantity = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.s24),
                      const _Label('Description'),
                      const SizedBox(height: AppTheme.s8),
                      ExpandableText(
                        text: product.description ?? 'No description available for this product.',
                      ),
                      const SizedBox(height: AppTheme.s24),
                      const _Label('Delivery & Returns'),
                      const SizedBox(height: AppTheme.s8),
                      const InfoTile(
                        icon: Icons.local_shipping_outlined,
                        title: 'Free delivery over Rs. 2,000',
                        subtitle: '2–4 business days across Nepal',
                      ),
                      const InfoTile(
                        icon: Icons.assignment_return_outlined,
                        title: '7-day returns',
                        subtitle: 'Free pickup · easy exchanges',
                      ),
                      const InfoTile(
                        icon: Icons.verified_outlined,
                        title: 'Authentic products',
                        subtitle: 'Verified original, guaranteed',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky action bar
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.s12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.local_offer_outlined, size: 12, color: AppTheme.textMuted),
                      SizedBox(width: 4),
                      Text(
                        'Not the price you want? Tap Bargain to make an offer.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.s8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.rMd),
                            ),
                            side: const BorderSide(color: AppTheme.primary),
                          ),
                          onPressed: () => BargainSheet.show(context, product.price),
                          child: const Text(
                            'Bargain',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, color: AppTheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.s12),
                      Expanded(
                        flex: 3,
                        child: FilledButton(
                          key: _addButtonKey,
                          onPressed: () => _handleAddToBag(product),
                          child: const Text('Add to Bag'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
          letterSpacing: 0.3,
        ),
      );
}

class _CircleBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.maybePop(context),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back, size: 20),
            ),
          ),
        ),
      );
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 20),
            ),
          ),
        ),
      );
}