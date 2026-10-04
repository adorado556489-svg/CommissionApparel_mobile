import 'package:flutter/material.dart';

/// Order lifecycle definition.
///
/// The persisted string values are kept backward compatible with existing
/// data ('Pending Coach Approval', 'Submitted to Admin', 'Processing').
/// All status logic (labels, ordering, allowed transitions) is derived from
/// [pipeline] so new states only need to be added in one place.
class OrderStatus {
  OrderStatus._();

  static const String pending = 'Pending Coach Approval';
  static const String submitted = 'Submitted to Admin';
  static const String inProduction = 'In Production';
  static const String shipped = 'Shipped';
  static const String delivered = 'Delivered';
  static const String cancelled = 'Cancelled';

  /// Legacy value written by older builds; treated as [inProduction].
  static const String legacyProcessing = 'Processing';

  /// Ordered happy-path pipeline.
  static const List<String> pipeline = [
    pending,
    submitted,
    inProduction,
    shipped,
    delivered,
  ];

  /// Statuses the admin controls (after the coach has submitted).
  static const List<String> adminControlled = [inProduction, shipped, delivered];

  static String normalize(String status) =>
      status == legacyProcessing ? inProduction : status;

  /// Position in [pipeline], or -1 for cancelled/unknown.
  static int stepIndex(String status) => pipeline.indexOf(normalize(status));

  /// The next status in the pipeline, or null if final/cancelled.
  static String? next(String status) {
    final i = stepIndex(status);
    if (i < 0 || i >= pipeline.length - 1) return null;
    return pipeline[i + 1];
  }

  /// Only forward, single-step moves along the pipeline are allowed, plus
  /// cancelling while still pending.
  static bool canTransition(String from, String to) {
    if (to == cancelled) return normalize(from) == pending;
    return next(from) == to;
  }

  static bool isFinal(String status) =>
      normalize(status) == delivered || status == cancelled;

  static String label(String status) {
    switch (normalize(status)) {
      case pending:
        return 'Pending';
      case submitted:
        return 'Submitted';
      case inProduction:
        return 'In Production';
      case shipped:
        return 'Shipped';
      case delivered:
        return 'Delivered';
      case cancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }

  static Color color(String status) {
    switch (normalize(status)) {
      case pending:
        return Colors.orange;
      case submitted:
        return Colors.blue;
      case inProduction:
        return Colors.indigo;
      case shipped:
        return Colors.teal;
      case delivered:
        return Colors.green;
      case cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Team store lifecycle values (persisted strings).
class StoreStatus {
  StoreStatus._();

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String declined = 'declined';
  static const String submittedToAdmin = 'submitted_to_admin';

  static String label(String status) {
    switch (status) {
      case pending:
        return 'Pending review';
      case approved:
        return 'Open';
      case declined:
        return 'Declined';
      case submittedToAdmin:
        return 'Order submitted';
      default:
        return status;
    }
  }

  static Color color(String status) {
    switch (status) {
      case pending:
        return Colors.orange;
      case approved:
        return Colors.green;
      case declined:
        return Colors.red;
      case submittedToAdmin:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

/// User account status values (persisted strings).
class UserStatus {
  UserStatus._();

  static const String active = 'active';
  static const String suspended = 'suspended';

  static const List<String> all = [active, suspended];
}
