import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────
enum OrderStatus {
  toPay,     // online payment not completed
  toShip,    // paid / COD placed, warehouse preparing
  toReceive, // shipped, in transit
  toReview,  // delivered, awaiting review
  delivered, // reviewed / order closed
  cancelled,
  returned,
  refunded,
}

enum PaymentStatus { pending, paid, failed, refunded }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.toPay:     return 'To pay';
      case OrderStatus.toShip:    return 'To ship';
      case OrderStatus.toReceive: return 'To receive';
      case OrderStatus.toReview:  return 'To review';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.returned:  return 'Return requested';
      case OrderStatus.refunded:  return 'Refunded';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.toPay:     return const Color(0xFFF59E0B);
      case OrderStatus.toShip:
      case OrderStatus.toReceive:
      case OrderStatus.toReview:  return const Color(0xFF3B82F6);
      case OrderStatus.delivered: return const Color(0xFF16A34A);
      case OrderStatus.cancelled: return const Color(0xFF6B7280);
      case OrderStatus.returned:  return const Color(0xFFF97316);
      case OrderStatus.refunded:  return const Color(0xFF16A34A);
    }
  }

  bool get isActive =>
      this == OrderStatus.toPay ||
      this == OrderStatus.toShip ||
      this == OrderStatus.toReceive ||
      this == OrderStatus.toReview;

  bool get isDelivered => this == OrderStatus.delivered;

  bool get isCancelled =>
      this == OrderStatus.cancelled ||
      this == OrderStatus.returned ||
      this == OrderStatus.refunded;

  /// The next status when "simulate next status" is tapped.
  OrderStatus? get nextStep {
    switch (this) {
      case OrderStatus.toPay:     return OrderStatus.toShip;
      case OrderStatus.toShip:    return OrderStatus.toReceive;
      case OrderStatus.toReceive: return OrderStatus.toReview;
      case OrderStatus.toReview:  return OrderStatus.delivered;
      default:                    return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Address — must match what your checkout created. Adjust fields if needed.
// ─────────────────────────────────────────────────────────────────────────────
class Address {
  final String id;
  final String label; // Home, Office, Other
  final String name;
  final String phone;
  final String line1;
  final String city;
  final String pincode;

  const Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.line1,
    required this.city,
    required this.pincode,
  });

  String get oneLine => '$line1, $city, $pincode';
}

// ─────────────────────────────────────────────────────────────────────────────
// Order item (frozen copy of a bag item, so historical orders survive edits)
// ─────────────────────────────────────────────────────────────────────────────
class OrderItem {
  final String productId;
  final String name;
  final String imageUrl;
  final String size;
  final String color;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
  });

  double get subtotal => price * quantity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tracking event
// ─────────────────────────────────────────────────────────────────────────────
class TrackingEvent {
  final String label;
  final String? description;
  final DateTime? timestamp;

  const TrackingEvent({
    required this.label,
    this.description,
    this.timestamp,
  });

  bool get isDone => timestamp != null;

  TrackingEvent copyWith({DateTime? timestamp, String? description}) =>
      TrackingEvent(
        label: label,
        description: description ?? this.description,
        timestamp: timestamp ?? this.timestamp,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Return request
// ─────────────────────────────────────────────────────────────────────────────
class ReturnRequest {
  final String id;
  final String orderId;
  final List<int> itemIndexes; // indexes into Order.items
  final String type;           // 'return' | 'exchange'
  final String reason;
  final String? exchangeSize;
  final DateTime createdAt;
  final String status;         // 'pending' | 'approved' | 'rejected'

  const ReturnRequest({
    required this.id,
    required this.orderId,
    required this.itemIndexes,
    required this.type,
    required this.reason,
    this.exchangeSize,
    required this.createdAt,
    this.status = 'pending',
  });

  String get itemSummary {
    if (itemIndexes.isEmpty) return 'No items';
    if (itemIndexes.length == 1) return '1 item';
    return '${itemIndexes.length} items';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order
// ─────────────────────────────────────────────────────────────────────────────
class Order {
  final String id;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final String paymentMethod;    // 'cod' | 'esewa' | 'khalti' | 'card'
  final PaymentStatus paymentStatus;
  final OrderStatus status;
  final Address address;
  final String shippingMethod;   // 'standard' | 'express' | 'pickup'
  final DateTime createdAt;
  final String? voucherCode;
  final List<TrackingEvent> timeline;
  final String? cancelReason;
  final ReturnRequest? returnRequest;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.address,
    required this.shippingMethod,
    required this.createdAt,
    this.voucherCode,
    required this.timeline,
    this.cancelReason,
    this.returnRequest,
  });

  bool get isCod => paymentMethod == 'cod';
  int get itemCount => items.fold(0, (s, x) => s + x.quantity);

  Order copyWith({
    String? id,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    List<TrackingEvent>? timeline,
    String? cancelReason,
    ReturnRequest? returnRequest,
  }) =>
      Order(
        id: id ?? this.id,
        items: items,
        subtotal: subtotal,
        shippingFee: shippingFee,
        discount: discount,
        total: total,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        status: status ?? this.status,
        address: address,
        shippingMethod: shippingMethod ?? this.shippingMethod,
        createdAt: createdAt ?? this.createdAt,  // Handle nullable case
        voucherCode: voucherCode,
        timeline: timeline ?? this.timeline,
        cancelReason: cancelReason ?? this.cancelReason,
        returnRequest: returnRequest ?? this.returnRequest,
      );
}