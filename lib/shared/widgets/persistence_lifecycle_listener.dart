import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bag_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/user_provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/reviews_provider.dart';
import '../providers/recently_viewed_provider.dart';

/// A widget that listens to app lifecycle changes and persists
/// all providers when the app is paused or goes inactive.
class PersistenceLifecycleListener extends ConsumerStatefulWidget {
  const PersistenceLifecycleListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PersistenceLifecycleListener> createState() =>
      _PersistenceLifecycleListenerState();
}

class _PersistenceLifecycleListenerState
    extends ConsumerState<PersistenceLifecycleListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(bagProvider.notifier).persistNow();
      ref.read(ordersProvider.notifier).persistNow();
      ref.read(wishlistProvider.notifier).persistNow();
      ref.read(userProvider.notifier).persistNow();
      ref.read(loyaltyProvider.notifier).persistNow();
      ref.read(reviewsProvider.notifier).persistNow();
      ref.read(recentlyViewedProvider.notifier).persistNow();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}