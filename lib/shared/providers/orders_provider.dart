import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../persistence/persisted_notifier.dart';

class OrdersNotifier extends PersistedNotifier<List<Order>> {
  OrdersNotifier()
      : super(
          storageKey: 'richiva.orders.v1',
          seed: _seed(),
        );

  // ── Seed (demo) ────────────────────────────────────────────────────────
  static List<Order> _seed() {
    final now = DateTime.now();
    return [
      Order(
        id: 'ORD-2401',
        items: [
          const OrderItem(
            productId: 'f1',
            name: 'Cashmere Sweater',
            imageUrl: 'https://picsum.photos/seed/f1/600/800',
            size: 'M', color: 'Beige', quantity: 1, price: 3499,
          ),
        ],
        subtotal: 3499, shippingFee: 0, discount: 0, total: 3499,
        paymentMethod: 'cod', paymentStatus: PaymentStatus.pending,
        status: OrderStatus.toShip,
        address: const Address(
          id: 'a1', label: 'Home', name: 'Demo User',
          phone: '9800000000', line1: 'Lazimpat, Ward 2',
          city: 'Kathmandu', pincode: '44600',
        ),
        shippingMethod: 'standard',
        createdAt: now.subtract(const Duration(hours: 6)),
        timeline: const [
          TrackingEvent(label: 'Order placed',      description: 'We received your order'),
          TrackingEvent(label: 'Preparing to ship', description: 'Warehouse is packing your item'),
          TrackingEvent(label: 'Shipped',           description: 'Handed to courier'),
          TrackingEvent(label: 'Delivered',         description: 'Arriving soon'),
        ],
      ),
      Order(
        id: 'ORD-2400',
        items: [
          const OrderItem(
            productId: 'n2', name: 'Ribbed Knit Top',
            imageUrl: 'https://picsum.photos/seed/n2/600/800',
            size: 'S', color: 'White', quantity: 2, price: 2199,
          ),
        ],
        subtotal: 4398, shippingFee: 0, discount: 0, total: 4398,
        paymentMethod: 'esewa', paymentStatus: PaymentStatus.paid,
        status: OrderStatus.delivered,
        address: const Address(
          id: 'a1', label: 'Home', name: 'Demo User',
          phone: '9800000000', line1: 'Lazimpat, Ward 2',
          city: 'Kathmandu', pincode: '44600',
        ),
        shippingMethod: 'express',
        createdAt: now.subtract(const Duration(days: 12)),
        timeline: const [
          TrackingEvent(label: 'Order placed',      description: 'Payment verified'),
          TrackingEvent(label: 'Preparing to ship', description: 'Packed'),
          TrackingEvent(label: 'Shipped',           description: 'In transit'),
          TrackingEvent(label: 'Delivered',         description: 'Delivered to Home'),
        ],
      ),
    ];
  }

  @override
  dynamic serialize(List<Order> state) =>
      state.map(_orderToJson).toList();

  @override
  List<Order> deserialize(dynamic json) =>
      (json as List).map((e) => _orderFromJson(e as Map<String, dynamic>)).toList();

  // ── Lookup ─────────────────────────────────────────────────────────────
  Order? getById(String id) {
    try {
      return state.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Create (called by checkout) ────────────────────────────────────────
  /// Keep this signature in sync with your checkout code. If your checkout
  /// calls it `createOrder(...)` or passes different args, adjust here.
  void add(Order order) => state = [order, ...state];

  // ── Track — simulate next status ───────────────────────────────────────
  void advanceStatus(String id) {
    state = [
      for (final o in state)
        if (o.id == id && o.status.nextStep != null)
          o.copyWith(
            status: o.status.nextStep!,
            paymentStatus: o.status == OrderStatus.toPay
                ? PaymentStatus.paid
                : o.paymentStatus,
            timeline: _stampNext(o.timeline),
          )
        else
          o,
    ];
  }

  List<TrackingEvent> _stampNext(List<TrackingEvent> timeline) {
    final idx = timeline.indexWhere((e) => e.timestamp == null);
    if (idx == -1) return timeline;
    final copy = [...timeline];
    copy[idx] = copy[idx].copyWith(timestamp: DateTime.now());
    return copy;
  }

  // ── Payment result (from order-result screen) ─────────────────────────
  void markPaid(String id) {
    state = [
      for (final o in state)
        if (o.id == id)
          o.copyWith(
            paymentStatus: PaymentStatus.paid,
            status: o.status == OrderStatus.toPay
                ? OrderStatus.toShip
                : o.status,
            timeline: _stampNext(o.timeline),
          )
        else
          o,
    ];
  }

  void markPaymentFailed(String id) {
    state = [
      for (final o in state)
        if (o.id == id)
          o.copyWith(paymentStatus: PaymentStatus.failed)
        else
          o,
    ];
  }

  // ── Cancel ─────────────────────────────────────────────────────────────
  void cancel(String id, String reason) {
    state = [
      for (final o in state)
        if (o.id == id)
          o.copyWith(
            status: OrderStatus.cancelled,
            paymentStatus: o.paymentStatus == PaymentStatus.paid
                ? PaymentStatus.refunded
                : PaymentStatus.pending,
            cancelReason: reason,
          )
        else
          o,
    ];
  }

  // ── Return / exchange ──────────────────────────────────────────────────
  void requestReturn({
    required String orderId,
    required List<int> itemIndexes,
    required String type,
    required String reason,
    String? exchangeSize,
  }) {
    final req = ReturnRequest(
      id: 'RET-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      itemIndexes: itemIndexes,
      type: type,
      reason: reason,
      exchangeSize: exchangeSize,
      createdAt: DateTime.now(),
    );
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(status: OrderStatus.returned, returnRequest: req)
        else
          o,
    ];
  }

  // ── Derived lists ──────────────────────────────────────────────────────
  List<Order> get active    => state.where((o) => o.status.isActive).toList();
  List<Order> get delivered => state.where((o) => o.status.isDelivered).toList();
  List<Order> get cancelled => state.where((o) => o.status.isCancelled).toList();
  List<ReturnRequest> get returns => state
      .where((o) => o.returnRequest != null)
      .map((o) => o.returnRequest!)
      .toList();

  // ─────────────────────────────────────────────────────────────────────────────
  // Serialization helpers
  // ─────────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _orderToJson(Order o) => {
        'id': o.id,
        'items': o.items
            .map((i) => {
                  'productId': i.productId,
                  'name': i.name,
                  'imageUrl': i.imageUrl,
                  'size': i.size,
                  'color': i.color,
                  'quantity': i.quantity,
                  'price': i.price,
                })
            .toList(),
        'subtotal': o.subtotal,
        'shippingFee': o.shippingFee,
        'discount': o.discount,
        'total': o.total,
        'paymentMethod': o.paymentMethod,
        'paymentStatus': o.paymentStatus.name,
        'status': o.status.name,
        'address': {
          'id': o.address.id,
          'label': o.address.label,
          'name': o.address.name,
          'phone': o.address.phone,
          'line1': o.address.line1,
          'city': o.address.city,
          'pincode': o.address.pincode,
        },
        'shippingMethod': o.shippingMethod,
        'createdAt': o.createdAt.toIso8601String(),
        'voucherCode': o.voucherCode,
        'timeline': o.timeline
            .map((e) => {
                  'label': e.label,
                  'description': e.description,
                  'timestamp': e.timestamp?.toIso8601String(),
                })
            .toList(),
        'cancelReason': o.cancelReason,
        'returnRequest': o.returnRequest == null
            ? null
            : {
                'id': o.returnRequest!.id,
                'orderId': o.returnRequest!.orderId,
                'itemIndexes': o.returnRequest!.itemIndexes,
                'type': o.returnRequest!.type,
                'reason': o.returnRequest!.reason,
                'exchangeSize': o.returnRequest!.exchangeSize,
                'createdAt': o.returnRequest!.createdAt.toIso8601String(),
                'status': o.returnRequest!.status,
              },
      };

  static Order _orderFromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        items: (j['items'] as List)
            .map((e) => OrderItem(
                  productId: e['productId'] as String,
                  name: e['name'] as String,
                  imageUrl: e['imageUrl'] as String,
                  size: e['size'] as String,
                  color: e['color'] as String,
                  quantity: e['quantity'] as int,
                  price: (e['price'] as num).toDouble(),
                ))
            .toList(),
        subtotal: (j['subtotal'] as num).toDouble(),
        shippingFee: (j['shippingFee'] as num).toDouble(),
        discount: (j['discount'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
        paymentMethod: j['paymentMethod'] as String,
        paymentStatus: PaymentStatus.values.byName(j['paymentStatus'] as String),
        status: OrderStatus.values.byName(j['status'] as String),
        address: Address(
          id: (j['address'] as Map)['id'] as String,
          label: (j['address'] as Map)['label'] as String,
          name: (j['address'] as Map)['name'] as String,
          phone: (j['address'] as Map)['phone'] as String,
          line1: (j['address'] as Map)['line1'] as String,
          city: (j['address'] as Map)['city'] as String,
          pincode: (j['address'] as Map)['pincode'] as String,
        ),
        shippingMethod: j['shippingMethod'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        voucherCode: j['voucherCode'] as String?,
        timeline: (j['timeline'] as List)
            .map((e) => TrackingEvent(
                  label: e['label'] as String,
                  description: e['description'] as String?,
                  timestamp: e['timestamp'] == null
                      ? null
                      : DateTime.parse(e['timestamp'] as String),
                ))
            .toList(),
        cancelReason: j['cancelReason'] as String?,
        returnRequest: j['returnRequest'] == null
            ? null
            : ReturnRequest(
                id: (j['returnRequest'] as Map)['id'] as String,
                orderId: (j['returnRequest'] as Map)['orderId'] as String,
                itemIndexes: ((j['returnRequest'] as Map)['itemIndexes'] as List)
                    .cast<int>(),
                type: (j['returnRequest'] as Map)['type'] as String,
                reason: (j['returnRequest'] as Map)['reason'] as String,
                exchangeSize:
                    (j['returnRequest'] as Map)['exchangeSize'] as String?,
                createdAt: DateTime.parse(
                    (j['returnRequest'] as Map)['createdAt'] as String),
                status: (j['returnRequest'] as Map)['status'] as String,
              ),
      );
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<Order>>((_) => OrdersNotifier());

final orderByIdProvider = Provider.family<Order?, String>((ref, id) {
  final orders = ref.watch(ordersProvider);
  try {
    return orders.firstWhere((o) => o.id == id);
  } catch (_) {
    return null;
  }
});

final activeOrdersProvider = Provider<List<Order>>((ref) =>
    ref.watch(ordersProvider).where((o) => o.status.isActive).toList());

final deliveredOrdersProvider = Provider<List<Order>>((ref) =>
    ref.watch(ordersProvider).where((o) => o.status.isDelivered).toList());

final cancelledOrdersProvider = Provider<List<Order>>((ref) =>
    ref.watch(ordersProvider).where((o) => o.status.isCancelled).toList());

final returnsProvider = Provider<List<ReturnRequest>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders
      .where((o) => o.returnRequest != null)
      .map((o) => o.returnRequest!)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});