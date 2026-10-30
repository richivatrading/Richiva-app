import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────────────────────────────────────
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.rLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: 'https://picsum.photos/seed/hero/1200/750',
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.border),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.s24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SUMMER 2025',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.s8),
                    const Text(
                      'The New Season\nCollection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: AppTheme.s16),
                    FilledButton(
                      onPressed: () => context.push('/collections/summer-essentials'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size(140, 44),
                      ),
                      child: const Text('Shop now'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLASH SALE RAIL (with countdown)
// ─────────────────────────────────────────────────────────────────────────────
class FlashSaleRail extends StatefulWidget {
  const FlashSaleRail({super.key});
  @override
  State<FlashSaleRail> createState() => _FlashSaleRailState();
}

class _FlashSaleRailState extends State<FlashSaleRail> {
  late final Timer _timer;
  Duration _remaining = const Duration(hours: 3, minutes: 24, seconds: 10);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 0) {
        _timer.cancel();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.s16, AppTheme.s24, AppTheme.s16, AppTheme.s12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('\u26A1', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text('Flash Sale',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.rPill),
                ),
                child: Text(
                  '${_two(_remaining.inHours)}:${_two(_remaining.inMinutes % 60)}:${_two(_remaining.inSeconds % 60)}',
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        _ProductRail(products: mockFlashSale, cardWidth: 150),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY ARC (horizontal circles)
// ─────────────────────────────────────────────────────────────────────────────
class CategoryArc extends StatelessWidget {
  const CategoryArc({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.s24),
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
          itemCount: mockCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppTheme.s16),
          itemBuilder: (_, i) => _CategoryBubble(category: mockCategories[i]),
        ),
      ),
    );
  }
}

class _CategoryBubble extends StatelessWidget {
  final Category category;
  const _CategoryBubble({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.rLg),
      onTap: () => context.push('/shop/${category.id}'),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: category.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: AppTheme.primary, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
// FEATURED RAIL (New Arrivals / Trending)
// ─────────────────────────────────────────────────────────────────────────────
class FeaturedRail extends StatelessWidget {
  final String title;
  final List<Product> products;
  final String actionRoute;

  const FeaturedRail({
    super.key,
    required this.title,
    required this.products,
    required this.actionRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          actionLabel: 'See all',
          onAction: () => context.push(actionRoute),
        ),
        _ProductRail(products: products, cardWidth: 160),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLLECTIONS GRID (2×2)
// ─────────────────────────────────────────────────────────────────────────────
class CollectionsGrid extends StatelessWidget {
  const CollectionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Curated Collections',
          actionLabel: 'See all',
          onAction: () => context.push('/categories'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.s12,
            mainAxisSpacing: AppTheme.s12,
            childAspectRatio: 0.72,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: mockCollections.map((c) {
              return InkWell(
                borderRadius: BorderRadius.circular(AppTheme.rLg),
                onTap: () => context.push('/collections/${c['id']}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.rLg),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: c['imageUrl'] as String,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppTheme.border),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppTheme.s12,
                        right: AppTheme.s12,
                        bottom: AppTheme.s12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              c['subtitle'] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENTLY VIEWED
// ─────────────────────────────────────────────────────────────────────────────
class RecentlyViewedRail extends StatelessWidget {
  const RecentlyViewedRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recently viewed'),
        _ProductRail(products: mockRecentlyViewed, cardWidth: 130),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERNAL — horizontal product rail
// ─────────────────────────────────────────────────────────────────────────────
class _ProductRail extends StatelessWidget {
  final List<Product> products;
  final double cardWidth;

  const _ProductRail({required this.products, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth * (4 / 3) + 72, // image + text block
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.s12),
        itemBuilder: (_, i) =>
            ProductCard(product: products[i], width: cardWidth),
      ),
    );
  }
}