import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/product.dart';
import '../persistence/persisted_notifier.dart';

class RecentlyViewedNotifier extends PersistedNotifier<List<Product>> {
  RecentlyViewedNotifier()
      : super(
          storageKey: 'richiva.recentlyViewed.v1',
          seed: mockRecentlyViewed,
        );

  static const _max = 10;

  @override
  dynamic serialize(List<Product> state) =>
      state.map((p) => p.id).toList();

  @override
  List<Product> deserialize(dynamic json) {
    final ids = (json as List).cast<String>();
    final all = allMockProducts;
    final byId = {for (final p in all) p.id: p};
    return ids
        .map((id) => byId[id])
        .whereType<Product>()
        .take(_max)
        .toList();
  }

  /// Called by ProductScreen when a product is opened.
  /// If you haven't wired this yet, add one line in ProductScreen's initState:
  /// `ref.read(recentlyViewedProvider.notifier).record(_product);`
  void record(Product product) {
    final without = state.where((p) => p.id != product.id).toList();
    state = [product, ...without].take(_max).toList();
  }

  void clear() => state = const [];
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<Product>>(
  (_) => RecentlyViewedNotifier(),
);