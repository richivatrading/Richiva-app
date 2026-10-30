import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Address
// ─────────────────────────────────────────────────────────────────────────────
class Address {
  final String id;
  final String label;     // 'Home', 'Work', 'Other'
  final String name;
  final String phone;
  final String province;
  final String city;
  final String street;
  final String? landmark;

  const Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.street,
    this.landmark,
  });

  String get singleLine =>
      '$street, $city, $province${landmark != null ? " ($landmark)" : ""}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'name': name,
        'phone': phone,
        'province': province,
        'city': city,
        'street': street,
        'landmark': landmark,
      };

  static Address fromMap(Map<String, dynamic> m) => Address(
        id: m['id'],
        label: m['label'],
        name: m['name'],
        phone: m['phone'],
        province: m['province'],
        city: m['city'],
        street: m['street'],
        landmark: m['landmark'],
      );

  Address copyWith({
    String? label,
    String? name,
    String? phone,
    String? province,
    String? city,
    String? street,
    String? landmark,
  }) =>
      Address(
        id: id,
        label: label ?? this.label,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        province: province ?? this.province,
        city: city ?? this.city,
        street: street ?? this.street,
        landmark: landmark ?? this.landmark,
      );
}

const List<String> kProvinces = [
  'Koshi',
  'Madhesh',
  'Bagmati',
  'Gandaki',
  'Lumbini',
  'Karnali',
  'Sudurpashchim',
];

// ─────────────────────────────────────────────────────────────────────────────
// Shipping method
// ─────────────────────────────────────────────────────────────────────────────
class ShippingMethod {
  final String id;
  final String name;
  final String eta;
  final String note;
  final double fee;

  const ShippingMethod({
    required this.id,
    required this.name,
    required this.eta,
    required this.note,
    required this.fee,
  });
}

const List<ShippingMethod> kShippingMethods = [
  ShippingMethod(
    id: 'standard',
    name: 'Standard Delivery',
    eta: '3–5 business days',
    note: 'Free on orders over Rs. 2,000',
    fee: 150,
  ),
  ShippingMethod(
    id: 'express',
    name: 'Express Delivery',
    eta: '1–2 business days',
    note: 'Available in Kathmandu Valley',
    fee: 300,
  ),
  ShippingMethod(
    id: 'store',
    name: 'Store Pickup',
    eta: 'Ready in 2 hours',
    note: 'Pick up from Richiva Thamel',
    fee: 0,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Payment method
// ─────────────────────────────────────────────────────────────────────────────
class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isOnline;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isOnline,
  });
}

const List<PaymentMethod> kPaymentMethods = [
  PaymentMethod(
    id: 'cod',
    name: 'Cash on Delivery',
    description: 'Pay when your order arrives',
    icon: Icons.money_outlined,
    isOnline: false,
  ),
  PaymentMethod(
    id: 'esewa',
    name: 'eSewa',
    description: 'Wallet payment',
    icon: Icons.account_balance_wallet_outlined,
    isOnline: true,
  ),
  PaymentMethod(
    id: 'khalti',
    name: 'Khalti',
    description: 'Wallet payment',
    icon: Icons.smartphone_outlined,
    isOnline: true,
  ),
  PaymentMethod(
    id: 'card',
    name: 'Debit / Credit Card',
    description: 'Card payment',
    icon: Icons.credit_card_outlined,
    isOnline: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Order
// ─────────────────────────────────────────────────────────────────────────────
enum OrderStatus {
  placed,
  confirmed,
  packed,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderLine {
  final String productId;
  final String name;
  final String imageUrl;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;
  final double listPrice;
  final bool negotiated;

  const OrderLine({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
    required this.listPrice,
    required this.negotiated,
  });
}

class OrderShipping {
  final String id;
  final String name;
  final double fee;
  final String eta;

  const OrderShipping({
    required this.id,
    required this.name,
    required this.fee,
    required this.eta,
  });
}

class OrderPayment {
  final String method;
  final String status; // 'cod-due', 'pending', 'paid', 'failed'

  const OrderPayment({
    required this.method,
    required this.status,
  });
}

class OrderTotals {
  final double list;
  final double offerSavings;
  final double voucherDiscount;
  final double shipping;
  final double total;

  const OrderTotals({
    required this.list,
    required this.offerSavings,
    required this.voucherDiscount,
    required this.shipping,
    required this.total,
  });
}

class Order {
  final String id;
  final int placedAt;
  final OrderStatus status;
  final List<OrderEvent> events;
  final List<OrderLine> lines;
  final Address address;
  final OrderShipping shipping;
  final OrderPayment payment;
  final OrderTotals totals;
  final String? voucherCode;
  final int points;

  const Order({
    required this.id,
    required this.placedAt,
    required this.status,
    required this.events,
    required this.lines,
    required this.address,
    required this.shipping,
    required this.payment,
    required this.totals,
    this.voucherCode,
    required this.points,
  });

  String get statusLabel => switch (status) {
        OrderStatus.placed => 'Placed',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.packed => 'Packed',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.outForDelivery => 'Out for delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };
}

class OrderEvent {
  final OrderStatus status;
  final int at;

  const OrderEvent({required this.status, required this.at});
}