import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_paths.dart';

/// Builds notification documents. Writes are added to a caller-provided
/// [WriteBatch] so a business change and its notification commit atomically.
class NotificationService {
  NotificationService._();

  static const String storeApproved = 'store_approved';
  static const String storeDeclined = 'store_declined';
  static const String orderPlaced = 'order_placed';
  static const String orderStatus = 'order_status';
  static const String orderPaid = 'order_paid';
  static const String batchSubmitted = 'batch_submitted';
  static const String batchStatus = 'batch_status';

  static void addToBatch(
    WriteBatch batch,
    FirebaseFirestore firestore, {
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic> data = const {},
  }) {
    if (userId.isEmpty) return;
    final ref = firestore.collection(FirestorePaths.notifications).doc();
    batch.set(ref, {
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'readAt': null,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> send(
    FirebaseFirestore firestore, {
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic> data = const {},
  }) async {
    final batch = firestore.batch();
    addToBatch(batch, firestore,
        userId: userId, type: type, title: title, message: message, data: data);
    await batch.commit();
  }
}
