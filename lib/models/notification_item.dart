import 'package:cloud_firestore/cloud_firestore.dart';

/// In-app notification model.
///
/// Represents notifications displayed to users (order updates, store
/// approvals, admin alerts, etc.). Structured so Firebase Cloud Messaging
/// can replace the temporary local data source later.
class NotificationItem {
  final String id;
  final String userId; // who receives it
  final String type; // e.g. 'store_approved', 'order_placed', 'order_finalized'
  final String title;
  final String message;
  final DateTime? readAt; // null = unread
  final Map<String, dynamic> data; // flexible payload for navigation, etc.
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.readAt,
    this.data = const {},
    required this.createdAt,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationItem(
      id: doc.id,
      userId: docData['userId'] ?? '',
      type: docData['type'] ?? '',
      title: docData['title'] ?? '',
      message: docData['message'] ?? '',
      readAt: (docData['readAt'] as Timestamp?)?.toDate(),
      data: Map<String, dynamic>.from(docData['data'] ?? {}),
      createdAt: (docData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Whether this notification has been read.
  bool get isRead => readAt != null;
  bool get isUnread => readAt == null;

  /// Mark as read by returning a copy with readAt set.
  NotificationItem markAsRead() {
    return NotificationItem(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      readAt: DateTime.now(),
      data: data,
      createdAt: createdAt,
    );
  }

  // Common notification types
  static const String typeStoreApproved = 'store_approved';
  static const String typeStoreDeclined = 'store_declined';
  static const String typeOrderPlaced = 'order_placed';
  static const String typeOrderFinalized = 'order_finalized';
  static const String typeBatchSubmitted = 'batch_submitted';
  static const String typeCoachRegistered = 'coach_registered';
  static const String typeQuoteReceived = 'quote_received';
  static const String typePricingApproved = 'pricing_approved';
}
