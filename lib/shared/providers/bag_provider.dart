import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/persisted_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bag item (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class BagItem {
  final String productId;
  final String name;
  final String imageUrl;
  final String size;
  final String color;
  final int quantity;
  final double price;

  const BagItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
  );

  BagItem copyWith({int? quantity}) => BagItem(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        size: size,
        color: color,
        quantity: quantity ?? this.quantity,
        price: price,
      );

  double get subtotal => price * quantity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bag JSON (unchanged from persistence migration)
// ─────────────────────────────────────────────────────────────────────────────
extension BagItemJson on BagItem {
  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'imageUrl': imageUrl,
        'size': size,
        'color': color,
        'quantity': quantity,
        'price': price,
      };

  static BagItem fromJson(Map<String, dynamic> j) => BagItem(
        productId: j['productId'] as String,
        name: j['name'] as String,
        imageUrl: j['imageUrl'] as String,
        size: j['size'] as String,
        color: j['color'] as String,
        quantity: j['quantity'] as int,
        price: (j['price'] as num).toDouble(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bag notifier (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class BagNotifier extends PersistedNotifier<List<BagItem>> {
  BagNotifier()
      : super(
          storageKey: kBagKey,
          seed: const [],
        );

  @override
  dynamic serialize(List<BagItem> state) => state.map((e) => e.toJson()).toList();

  @override
  List<BagItem> deserialize(dynamic json) => (json as List)
      .map((e) => BagItemJson.fromJson(e as Map<String, dynamic>))
      .toList();

  void add(BagItem item) {
    final index = state.indexWhere((x) =>
        x.productId == item.productId &&
        x.size == item.size &&
        x.color == item.color);
    if (index == -1) {
      state = [...state, item];
    } else {
      final copy = [...state];
      copy[index] = copy[index].copyWith(
        quantity: copy[index].quantity + item.quantity,
      );
      state = copy;
    }
  }

  void removeAt(int index) {
    state = [...state]..removeAt(index);
  }

  void updateQuantity(int index, int quantity) {
    if (quantity < 1) return;
    final copy = [...state];
    copy[index] = copy[index].copyWith(quantity: quantity);
    state = copy;
  }

  void clear() => state = const [];

  double get subtotal => state.fold(0, (sum, x) => sum + x.subtotal);
  int get itemCount => state.fold(0, (sum, x) => sum + x.quantity);
}

final bagProvider =
    StateNotifierProvider<BagNotifier, List<BagItem>>((ref) => BagNotifier());

final bagSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(bagProvider);
  return items.fold(0, (s, x) => s + x.subtotal);
});

// ─────────────────────────────────────────────────────────────────────────────
// Shipping rules (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
const double kFreeShippingThreshold = 2000;
const double kStandardShippingFee = 150;

// ─────────────────────────────────────────────────────────────────────────────
// Voucher class (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class Voucher {
  final String code;
  final String description;
  final double? discountRs;
  final double? discountPercent;
  final bool freeShipping;
  final double minOrderValue;

  const Voucher({
    required this.code,
    required this.description,
    this.discountRs,
    this.discountPercent,
    this.freeShipping = false,
    this.minOrderValue = 0,
  });

  double computeDiscount(double subtotal) {
    if (freeShipping) return 0;
    if (discountRs != null) {
      return discountRs!.clamp(0, subtotal).toDouble();
    }
    if (discountPercent != null) {
      return (subtotal * discountPercent! / 100).clamp(0, subtotal).toDouble();
    }
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Voucher JSON
// ─────────────────────────────────────────────────────────────────────────────
extension VoucherJson on Voucher {
  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'discountRs': discountRs,
        'discountPercent': discountPercent,
        'freeShipping': freeShipping,
        'minOrderValue': minOrderValue,
      };

  static Voucher fromJson(Map<String, dynamic> j) => Voucher(
        code: j['code'] as String,
        description: j['description'] as String,
        discountRs: (j['discountRs'] as num?)?.toDouble(),
        discountPercent: (j['discountPercent'] as num?)?.toDouble(),
        freeShipping: j['freeShipping'] as bool? ?? false,
        minOrderValue: (j['minOrderValue'] as num?)?.toDouble() ?? 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Seed data (was kAvailableVouchers)
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, Voucher> kSeedVouchers = {
  'SUMMER10': Voucher(
    code: 'SUMMER10',
    description: '10% off your order',
    discountPercent: 10,
    minOrderValue: 1000,
  ),
  'FLAT500': Voucher(
    code: 'FLAT500',
    description: 'Rs. 500 off',
    discountRs: 500,
    minOrderValue: 2000,
  ),
  'FREESHIP': Voucher(
    code: 'FREESHIP',
    description: 'Free shipping',
    freeShipping: true,
  ),
  'WELCOME15': Voucher(
    code: 'WELCOME15',
    description: '15% off for new customers',
    discountPercent: 15,
    minOrderValue: 1500,
  ),
};

/// Deprecated alias — kept so any missed reference still compiles.
/// New code should use `voucherCatalogProvider`.
const Map<String, Voucher> kAvailableVouchers = kSeedVouchers;

// ─────────────────────────────────────────────────────────────────────────────
// Voucher catalog (NEW — persisted, dynamically addable)
// ─────────────────────────────────────────────────────────────────────────────
class VoucherCatalogNotifier
    extends PersistedNotifier<Map<String, Voucher>> {
  VoucherCatalogNotifier()
      : super(
          storageKey: kVoucherCatalogKey,
          seed: kSeedVouchers,
        );

  @override
  dynamic serialize(Map<String, Voucher> state) =>
      state.map((k, v) => MapEntry(k, v.toJson()));

  @override
  Map<String, Voucher> deserialize(dynamic json) {
    final m = json as Map<String, dynamic>;
    return m.map(
      (k, v) => MapEntry(k, VoucherJson.fromJson(v as Map<String, dynamic>)),
    );
  }

  /// Add or replace a voucher in the catalog.
  void add(Voucher v) => state = {...state, v.code: v};

  /// Remove a voucher by code. No-op if not present.
  void remove(String code) {
    if (!state.containsKey(code)) return;
    state = Map.from(state)..remove(code);
  }
}

final voucherCatalogProvider =
    StateNotifierProvider<VoucherCatalogNotifier, Map<String, Voucher>>(
  (_) => VoucherCatalogNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Applied voucher (unchanged except applyCode signature)
// ─────────────────────────────────────────────────────────────────────────────
class VoucherNotifier extends StateNotifier<Voucher?> {
  VoucherNotifier() : super(null);

  String? applyCode(
    String rawCode,
    double subtotal,
    Map<String, Voucher> catalog,
  ) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return 'Enter a code';
    final v = catalog[code];
    if (v == null) return 'Invalid voucher code';
    if (subtotal < v.minOrderValue) {
      return 'Minimum order Rs. ${v.minOrderValue.toStringAsFixed(0)} required';
    }
    state = v;
    return null;
  }

  void remove() => state = null;
}

final voucherProvider =
    StateNotifierProvider<VoucherNotifier, Voucher?>((ref) => VoucherNotifier());

// ─────────────────────────────────────────────────────────────────────────────
// Derived totals (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
final bagShippingProvider = Provider<double>((ref) {
  final subtotal = ref.watch(bagSubtotalProvider);
  final voucher = ref.watch(voucherProvider);
  if (subtotal == 0) return 0;
  if (voucher?.freeShipping == true) return 0;
  if (subtotal >= kFreeShippingThreshold) return 0;
  return kStandardShippingFee;
});

final bagDiscountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(bagSubtotalProvider);
  final voucher = ref.watch(voucherProvider);
  return voucher?.computeDiscount(subtotal) ?? 0;
});

final bagTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(bagSubtotalProvider);
  final shipping = ref.watch(bagShippingProvider);
  final discount = ref.watch(bagDiscountProvider);
  return (subtotal + shipping - discount).clamp(0, double.infinity);
});