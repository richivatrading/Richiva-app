import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/recently_viewed_provider.dart';
import '../../shared/providers/user_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/account_widgets.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final recentlyViewed = ref.watch(recentlyViewedProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── App bar
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: const Text('Account'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
                const SizedBox(width: 4),
              ],
            ),

            if (user == null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.s32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline,
                            size: 56, color: AppTheme.textMuted),
                        const SizedBox(height: AppTheme.s16),
                        Text('You\'re signed out',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium),
                        const SizedBox(height: AppTheme.s8),
                        const Text(
                          'Sign in to see your orders, Gold Points, and more.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: AppTheme.s24),
                        FilledButton(
                          onPressed: () => context.go('/login'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(200, 52),
                          ),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // ── Profile
              const SliverToBoxAdapter(child: ProfileHeader()),

              // ── Gold Points
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: AppTheme.s8, bottom: AppTheme.s16),
                  child: GoldPointsCard(),
                ),
              ),

              // ── Services grid
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: AppTheme.s8),
                  child: ServicesGrid(),
                ),
              ),

              // ── Order tabs
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: AppTheme.s8, bottom: AppTheme.s16),
                  child: OrderStatusTabs(),
                ),
              ),

              // ── Recently viewed
              SliverToBoxAdapter(
                child: RecentlyViewedSection(products: recentlyViewed),
              ),

              // ── Active offers
              const SliverToBoxAdapter(child: ActiveOffersSection()),

              // ── Care links + sign out
              const SliverToBoxAdapter(child: CareLinksSection()),
            ],
          ],
        ),
      ),
    );
  }
}