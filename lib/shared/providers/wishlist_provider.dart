import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/persisted_notifier.dart';

class WishlistNotifier extends PersistedNotifier<Set<String>> {
  WishlistNotifier()
      : super(
          storageKey: 'richiva.wishlist.v1',
          seed: const {'n1', 'f3'},
        );

  @override
  dynamic serialize(Set<String> state) => state.toList();

  @override
  Set<String> deserialize(dynamic json) =>
      (json as List).cast<String>().toSet();

  bool contains(String productId) => state.contains(productId);

  void toggle(String productId) {
    final copy = {...state};
    if (!copy.add(productId)) copy.remove(productId);
    state = copy;
  }

  void add(String productId) => state = {...state, productId};
  void remove(String productId) => state = {...state}..remove(productId);
  void clear() => state = const {};
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, Set<String>>(
  (_) => WishlistNotifier(),
);

final wishlistCountProvider =
    Provider<int>((ref) => ref.watch(wishlistProvider).length);