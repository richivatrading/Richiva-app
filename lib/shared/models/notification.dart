class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) => NotificationModel(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
      );
}

enum NotificationType { promo, order, system, payment, delivery }