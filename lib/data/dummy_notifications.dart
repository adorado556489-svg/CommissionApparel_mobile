import '../models/notification_item.dart';

/// Dummy notifications for testing the notification UI across roles.
final List<NotificationItem> dummyNotifications = [
  // ── Admin Notifications ─────────────────────────────────────────────────
  NotificationItem(
    id: 'notif-1',
    userId: 'user-admin-1',
    type: NotificationItem.typeCoachRegistered,
    title: 'New Coach Registration',
    message: 'David Chen from Metro Track Club has registered and is '
        'awaiting approval.',
    data: {'coachId': 'user-coach-3'},
    createdAt: DateTime(2024, 8, 1, 10, 30),
  ),
  NotificationItem(
    id: 'notif-2',
    userId: 'user-admin-1',
    type: NotificationItem.typeQuoteReceived,
    title: 'New Quote Request',
    message: 'Michael Thompson from Central High School submitted a quote '
        'request for basketball apparel.',
    data: {'quoteId': 'quote-1'},
    createdAt: DateTime(2024, 7, 15, 14, 0),
  ),
  NotificationItem(
    id: 'notif-3',
    userId: 'user-admin-1',
    type: NotificationItem.typeBatchSubmitted,
    title: 'Order Batch Submitted',
    message: 'Marcus Johnson submitted batch #batch-2024-06-001 for '
        'Riverside Academy Basketball (1 order, \$240.00).',
    data: {'batchId': 'batch-2024-06-001', 'storeId': 'store-1'},
    readAt: DateTime(2024, 6, 21),
    createdAt: DateTime(2024, 6, 20, 16, 0),
  ),

  // ── Coach Notifications (Marcus Johnson) ────────────────────────────────
  NotificationItem(
    id: 'notif-4',
    userId: 'user-coach-1',
    type: NotificationItem.typeStoreApproved,
    title: 'Store Approved',
    message: 'Your store "Riverside Academy Basketball" has been approved '
        'by the admin. You can now set pricing and go live.',
    data: {'storeId': 'store-1'},
    readAt: DateTime(2024, 3, 5),
    createdAt: DateTime(2024, 3, 5, 9, 0),
  ),
  NotificationItem(
    id: 'notif-5',
    userId: 'user-coach-1',
    type: NotificationItem.typePricingApproved,
    title: 'Pricing Approved',
    message: 'Your pricing for "Riverside Academy Basketball" has been '
        'approved. The store is now live and accepting orders!',
    data: {'storeId': 'store-1'},
    readAt: DateTime(2024, 6, 16),
    createdAt: DateTime(2024, 6, 15, 11, 0),
  ),
  NotificationItem(
    id: 'notif-6',
    userId: 'user-coach-1',
    type: NotificationItem.typeOrderPlaced,
    title: 'New Order Received',
    message: 'Jennifer Martinez placed an order for Carlos Martinez '
        '(\$150.00) in Riverside Academy Basketball.',
    data: {'orderId': 'order-1', 'storeId': 'store-1'},
    createdAt: DateTime(2024, 7, 1, 15, 30),
  ),
  NotificationItem(
    id: 'notif-7',
    userId: 'user-coach-1',
    type: NotificationItem.typeOrderPlaced,
    title: 'New Order Received',
    message: 'John Smith placed an order for Emily Smith '
        '(\$85.00) in Riverside Academy Basketball.',
    data: {'orderId': 'order-2', 'storeId': 'store-1'},
    createdAt: DateTime(2024, 7, 5, 12, 0),
  ),

  // ── Coach Notifications (Sarah Williams) ────────────────────────────────
  NotificationItem(
    id: 'notif-8',
    userId: 'user-coach-2',
    type: NotificationItem.typeStoreApproved,
    title: 'Store Approved',
    message: 'Your store "Northview Football Program" has been approved. '
        'Please set retail pricing to go live.',
    data: {'storeId': 'store-2'},
    createdAt: DateTime(2024, 5, 1, 10, 0),
  ),

  // ── Parent Notifications (Jennifer Martinez) ────────────────────────────
  NotificationItem(
    id: 'notif-9',
    userId: 'user-parent-1',
    type: NotificationItem.typeOrderFinalized,
    title: 'Order Finalized',
    message: 'Your order for Carlos Martinez in Summer Hoops Camp 2024 '
        'has been finalized and submitted for processing.',
    data: {'orderId': 'order-5', 'storeId': 'store-3'},
    readAt: DateTime(2024, 7, 21),
    createdAt: DateTime(2024, 7, 20, 8, 0),
  ),
];

// ── Convenience lookups ───────────────────────────────────────────────────

/// Notifications for a specific user.
List<NotificationItem> notificationsForUser(String userId) =>
    dummyNotifications.where((n) => n.userId == userId).toList();

/// Unread notifications for a specific user.
List<NotificationItem> unreadNotificationsForUser(String userId) =>
    dummyNotifications
        .where((n) => n.userId == userId && n.isUnread)
        .toList();
