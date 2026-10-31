import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/bag_provider.dart';
import '../../shared/providers/product_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/home_sections.dart';
import '../../shared/widgets/state_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bagCount =
        ref.watch(bagProvider).fold<int>(0, (s, x) => s + x.quantity);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: AppTheme.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              titleSpacing: AppTheme.s16,
              title: Text(
                'RICHIVA',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push('/search'),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () => context.push('/bag'),
                    ),
                    if (bagCount > 0)
                      Positioned(
                        right: 8,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(AppTheme.rPill),
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
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
                const SizedBox(width: 4),
              ],
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: AppTheme.s8),
                child: HeroBanner(),
              ),
            ),
            const SliverToBoxAdapter(child: CategoryArc()),
            const SliverToBoxAdapter(child: FlashSaleRail()),
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, child) {
                  final newArrivalsAsync = ref.watch(newArrivalsProvider);
                  return newArrivalsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 250,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FullScreenError(
                        error: error,
                        message: 'Could not load products',
                        onRetry: () => ref.invalidate(newArrivalsProvider),
                      ),
                    ),
                    data: (products) => FeaturedRail(
                      title: 'New Arrivals (API)',
                      products: products,
                      actionRoute: '/categories',
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: FeaturedRail(
                title: 'Trending Now',
                products: const [],
                actionRoute: '/categories',
              ),
            ),
            const SliverToBoxAdapter(child: CollectionsGrid()),
            const SliverToBoxAdapter(child: RecentlyViewedRail()),
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.s32)),
          ],
        ),
      ),
    );
  }
}