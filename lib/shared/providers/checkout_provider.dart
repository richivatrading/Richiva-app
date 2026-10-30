import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checkout.dart';
import '../models/product.dart';
import 'bag_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Address book (in-memory — survives hot reload, dies on full restart)
// ─────────────────────────────────────────────────────────────────────────────
class AddressNotifier extends StateNotifier<List<Address>> {
  AddressNotifier() : super([
    Address(
      id: 'addr-1',
      label: 'Home',
      name: 'Asha Sharma',
      phone: '9800000001',
      province: 'Bagmati',
      city: 'Kathmandu',
      street: 'Thamel Marg 12',
      landmark: 'Near Garden of Dreams',
    ),
    Address(
      id: 'addr-2',
      label: 'Work',
      name: 'Asha Sharma',
      phone: '9800000001',
      province: 'Bagmati',
      city: 'Lalitpur',
      street: 'Patan Industrial Estate, Block B',
      landmark: 'Gate 3',
    ),
  ]);

  void add(Address a) => state = [...state, a];
  void remove(String id) => state = state.where((a) => a.id != id).toList();
  void setDefault(String id) {
    state = state.map((a) => a.copyWith(label: a.id == id ? a.label : a.label)).toList();
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, List<Address>>((ref) => AddressNotifier());

// ─────────────────────────────────────────────────────────────────────────────
// Checkout flow state (address → shipping → payment → review)
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutState {
  final String? addressId;
  final String? shippingId;
  final String? paymentId;
  final Map<String, String> scenario;

  const CheckoutState({
    this.addressId,
    this.shippingId,
    this.paymentId,
    this.scenario = const {},
  });

  CheckoutState copyWith({
    String? addressId,
    String? shippingId,
    String? paymentId,
    Map<String, String>? scenario,
  }) =>
      CheckoutState(
        addressId: addressId ?? this.addressId,
        shippingId: shippingId ?? this.shippingId,
        paymentId: paymentId ?? this.paymentId,
        scenario: scenario ?? this.scenario,
      );
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(const CheckoutState());

  void setAddress(String id) => state = state.copyWith(addressId: id);
  void setShipping(String id) => state = state.copyWith(shippingId: id);
  void setPayment(String id) => state = state.copyWith(paymentId: id);
  void setScenario(Map<String, String> s) => state = state.copyWith(scenario: s);
  void reset() => state = const CheckoutState();
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) => CheckoutNotifier());

// ─────────────────────────────────────────────────────────────────────────────
// Computed selections (nullable — screens handle null with validation)
// ─────────────────────────────────────────────────────────────────────────────
final selectedAddressProvider = Provider<Address?>((ref) {
  final id = ref.watch(checkoutProvider).addressId;
  if (id == null) return null;
  return ref.watch(addressProvider).firstWhere((a) => a.id == id, orElse: () => null as Address);
});

final selectedShippingProvider = Provider<ShippingMethod?>((ref) {
  final id = ref.watch(checkoutProvider).shippingId;
  if (id == null) return null;
  return kShippingMethods.firstWhere((s) => s.id == id, orElse: () => null as ShippingMethod);
});

final selectedPaymentProvider = Provider<PaymentMethod?>((ref) {
  final id = ref.watch(checkoutProvider).paymentId;
  if (id == null) return null;
  return kPaymentMethods.firstWhere((p) => p.id == id, orElse: () => null as PaymentMethod);
});

// ─────────────────────────────────────────────────────────────────────────────
// Orders (in-memory list — add persistence later if needed)
// ─────────────────────────────────────────────────────────────────────────────
class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier(this._ref) : super([]) {
    _seedDemo();
  }

  final Ref _ref;

  void _seedDemo() {
    final demo = Order(
      id: 'RCH-1001',
      placedAt: DateTime.now().millisecondsSinceEpoch - 86400000,
      status: OrderStatus.delivered,
      events: [
        OrderEvent(status: OrderStatus.placed, at: DateTime.now().millisecondsSinceEpoch - 86400000),
        OrderEvent(status: OrderStatus.confirmed, at: DateTime.now().millisecondsSinceEpoch - 82800000),
        OrderEvent(status: OrderStatus.packed, at: DateTime.now().millisecondsSinceEpoch - 75600000),
        OrderEvent(status: OrderStatus.shipped, at: DateTime.now().millisecondsSinceEpoch - 43200000),
        OrderEvent(status: OrderStatus.outForDelivery, at: DateTime.now().millisecondsSinceEpoch - 8640000),
        OrderEvent(status: OrderStatus.delivered, at: DateTime.now().millisecondsSinceEpoch - 1000),
      ],
      lines: [
        OrderLine(
          productId: 'f1',
          name: 'Cashmere Sweater',
          imageUrl: 'https://picsum.photos/seed/f1/600/800',
          size: 'M',
          color: 'Black',
          quantity: 1,
          unitPrice: 3499,
          listPrice: 6999,
          negotiated: false,
        ),
      ],
      address: const Address(
        id: 'addr-1',
        label: 'Home',
        name: 'Asha Sharma',
        phone: '9800000001',
        province: 'Bagmati',
        city: 'Kathmandu',
        street: 'Thamel Marg 12',
        landmark: 'Near Garden of Dreams',
      ),
      shipping: const OrderShipping(
        id: 'standard',
        name: 'Standard Delivery',
        fee: 150,
        eta: '3–5 business days',
      ),
      payment: const OrderPayment(method: 'cod', status: 'paid'),
      totals: const OrderTotals(
        list: 6999,
        offerSavings: 3500,
        voucherDiscount: 0,
        shipping: 150,
        total: 3649,
      ),
      voucherCode: null,
      points: 36,
    );
    state = [demo];
  }

  String placeOrder() {
    final bagItems = _ref.read(bagProvider);
    final checkout = _ref.read(checkoutProvider);
    final subtotal = _ref.read(bagSubtotalProvider);
    final shippingFee = _ref.read(bagShippingProvider);
    final voucherDiscount = _ref.read(bagDiscountProvider);
    final total = _ref.read(bagTotalProvider);
    final voucher = _ref.read(voucherProvider);

    final address = _ref.read(selectedAddressProvider)!;
    final shippingMethod = _ref.read(selectedShippingProvider)!;
    final paymentMethod = _ref.read(selectedPaymentProvider)!;

    final now = DateTime.now().millisecondsSinceEpoch;
    final orderId = 'RCH-${now.toString().substring(6)}';

    final lines = bagItems.map((item) => OrderLine(
          productId: item.productId,
          name: item.name,
          imageUrl: item.imageUrl,
          size: item.size,
          color: item.color,
          quantity: item.quantity,
          unitPrice: item.price,
          listPrice: item.price,
          negotiated: false,
        )).toList();

    final order = Order(
      id: orderId,
      placedAt: now,
      status: OrderStatus.placed,
      events: [OrderEvent(status: OrderStatus.placed, at: now)],
      lines: lines,
      address: address,
      shipping: OrderShipping(
        id: shippingMethod.id,
        name: shippingMethod.name,
        fee: shippingFee,
        eta: shippingMethod.eta,
      ),
      payment: OrderPayment(
        method: paymentMethod.id,
        status: paymentMethod.isOnline ? 'pending' : 'cod-due',
      ),
      totals: OrderTotals(
        list: subtotal,
        offerSavings: 0,
        voucherDiscount: voucherDiscount,
        shipping: shippingFee,
        total: total,
      ),
      voucherCode: voucher?.code,
      points: total.toInt(),
    );

    state = [order, ...state];

    _ref.read(bagProvider.notifier).clear();
    final applied = _ref.read(voucherProvider);
    _ref.read(voucherProvider.notifier).remove();
    // Loyalty vouchers are one-time use — consume them from the catalog.
    if (applied != null && applied.code.startsWith('LOYAL')) {
      _ref.read(voucherCatalogProvider.notifier).remove(applied.code);
    }
    _ref.read(checkoutProvider.notifier).reset();

    return orderId;
  }

  void advanceOrder(String id, OrderStatus nextStatus) {
    final index = state.indexWhere((o) => o.id == id);
    if (index == -1) return;
    final order = state[index];
    if (order.status.index >= OrderStatus.values.length - 1) return;
    final next = OrderStatus.values[order.status.index + 1];
    if (next != nextStatus) return;
    final updated = Order(
      id: order.id,
      placedAt: order.placedAt,
      status: nextStatus,
      events: [...order.events, OrderEvent(status: nextStatus, at: DateTime.now().millisecondsSinceEpoch)],
      lines: order.lines,
      address: order.address,
      shipping: order.shipping,
      payment: order.payment,
      totals: order.totals,
      voucherCode: order.voucherCode,
      points: order.points,
    );
    state = [...state]..[index] = updated;
  }

  void updateOrder(String id, Order Function(Order) updater) {
    final index = state.indexWhere((o) => o.id == id);
    if (index == -1) return;
    state = [...state]..[index] = updater(state[index]);
  }
}

final ordersProvider =
    StateNotifierProvider<OrderNotifier, List<Order>>((ref) => OrderNotifier(ref));