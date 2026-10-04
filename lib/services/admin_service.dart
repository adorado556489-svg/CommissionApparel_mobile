import '../models/user.dart';
import '../models/landing_collection.dart';
import '../models/testimonial.dart';
import '../models/team_store.dart';
import '../models/parent_order.dart';
import '../constants/firestore_paths.dart';
import '../constants/statuses.dart';
import 'notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  
  static Future<String?> updateCoach(FirebaseFirestore firestore, User admin, User coach, {
    required String firstName,
    required String lastName,
    required String email,
    required String organization,
    required String phone,
    required String sport,
    required String status,
  }) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final qs = await firestore.collection('users').where('email', isEqualTo: email).get();
      if (qs.docs.isNotEmpty && qs.docs.first.id != coach.id) {
        return 'Email already in use.';
      }
      
      final doc = await firestore.collection('users').doc(coach.id).get();
      if (doc.exists) {
        await firestore.collection('users').doc(coach.id).update({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'organization': organization,
          'phone': phone,
          'sport': sport,
          'status': status,
        });
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static String? resetCoachPassword(User admin, User coach, String newPassword) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static Future<String?> deleteCoach(FirebaseFirestore firestore, User admin, String coachId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('users').doc(coachId).delete();
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static Future<String?> markDirectBatchAddressed(FirebaseFirestore firestore, User admin, String batchId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final qs = await firestore.collection('parentOrders').where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          if (doc.data()['teamStoreId'] == null) {
            batch.update(doc.reference, {'status': 'Processing', 'isArchived': true});

            // Notify parent
            final parentId = doc.data()['userId'];
            if (parentId != null) {
              final notifRef = firestore.collection('notifications').doc();
              batch.set(notifRef, {
                'userId': parentId,
                'type': 'order_processing',
                'title': 'Direct Order Processing',
                'message': 'Your direct order for ${doc.data()['athleteFirstName']} is now processing!',
                'readAt': null,
                'data': {'orderId': doc.id},
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
        await batch.commit();
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static Future<String?> markStoreBatchAddressed(FirebaseFirestore firestore, User admin, String batchId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final qs = await firestore.collection('parentOrders').where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          if (doc.data()['teamStoreId'] != null) {
            batch.update(doc.reference, {'status': 'Processing', 'isArchived': true});
            
            // Notify parent
            final parentId = doc.data()['userId'];
            if (parentId != null) {
              final notifRef = firestore.collection('notifications').doc();
              batch.set(notifRef, {
                'userId': parentId,
                'type': 'order_processing',
                'title': 'Order Processing',
                'message': 'Your order for ${doc.data()['athleteFirstName']} has been reviewed by the admin and is now processing!',
                'readAt': null,
                'data': {'orderId': doc.id},
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
        await batch.commit();
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static Future<String?> deleteArchivedOrderBatch(FirebaseFirestore firestore, User admin, String batchId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final qs = await firestore.collection('parentOrders').where('batchId', isEqualTo: batchId).where('isArchived', isEqualTo: true).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static String? createLandingCollection(User admin, LandingCollection collection) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? updateLandingCollection(User admin, LandingCollection updatedCollection) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? deleteLandingCollection(User admin, String collectionId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? createTestimonial(User admin, Testimonial testimonial) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? updateTestimonial(User admin, Testimonial updatedTestimonial) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? deleteTestimonial(User admin, String testimonialId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? updateHeroSettings(User admin, {required String subtitle, String? mediaPath, String? mediaType}) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? removeHeroMedia(User admin) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  // ---- Store approvals & monitoring -----------------------------------------

  /// Approves a store request in ONE atomic write: the store goes live
  /// (approved + pricing approved), its owner is upgraded to coach, and the
  /// owner is notified. Returns null on success or an error message.
  static Future<String?> approveStore(FirebaseFirestore firestore, User admin, TeamStore store) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      final batch = firestore.batch();
      batch.update(firestore.collection(FirestorePaths.teamStores).doc(store.id), {
        'status': StoreStatus.approved,
        'pricingApproved': true,
        'isArchived': false,
        'declineReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(firestore.collection(FirestorePaths.users).doc(store.userId), {
        'role': 'coach',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      NotificationService.addToBatch(
        batch,
        firestore,
        userId: store.userId,
        type: NotificationService.storeApproved,
        title: 'Store approved',
        message: 'Your store "${store.name}" is approved. Open My Store to add products and share it.',
        data: {'storeId': store.id},
      );
      await batch.commit();
    } catch (e) {
      return 'Could not approve the store. ${_friendly(e)}';
    }
    return null;
  }

  /// Declines a store request and tells the owner why.
  static Future<String?> declineStore(FirebaseFirestore firestore, User admin, TeamStore store, {String? reason}) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final trimmed = reason?.trim();
    try {
      final batch = firestore.batch();
      batch.update(firestore.collection(FirestorePaths.teamStores).doc(store.id), {
        'status': StoreStatus.declined,
        'declineReason': (trimmed == null || trimmed.isEmpty) ? null : trimmed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      NotificationService.addToBatch(
        batch,
        firestore,
        userId: store.userId,
        type: NotificationService.storeDeclined,
        title: 'Store request declined',
        message: (trimmed == null || trimmed.isEmpty)
            ? 'Your request for "${store.name}" was declined. You may submit a new request.'
            : 'Your request for "${store.name}" was declined: $trimmed',
        data: {'storeId': store.id},
      );
      await batch.commit();
    } catch (e) {
      return 'Could not decline the store. ${_friendly(e)}';
    }
    return null;
  }

  /// Suspends (archives) or restores a store. A suspended store is hidden from
  /// customers and its owner cannot edit or sell until it is restored.
  static Future<String?> setStoreArchived(FirebaseFirestore firestore, User admin, TeamStore store, bool archived) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      final batch = firestore.batch();
      batch.update(firestore.collection(FirestorePaths.teamStores).doc(store.id), {
        'isArchived': archived,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      NotificationService.addToBatch(
        batch,
        firestore,
        userId: store.userId,
        type: NotificationService.storeDeclined,
        title: archived ? 'Store suspended' : 'Store restored',
        message: archived
            ? 'Your store "${store.name}" has been suspended by the platform. Contact support for details.'
            : 'Your store "${store.name}" has been restored.',
        data: {'storeId': store.id},
      );
      await batch.commit();
    } catch (e) {
      return 'Could not update the store. ${_friendly(e)}';
    }
    return null;
  }

  // ---- Master order (batch) lifecycle ----------------------------------------

  /// Moves every order of [batchId] to the next production stage
  /// (Submitted -> In Production -> Shipped -> Delivered), records the change
  /// in each order's timeline and notifies the customers and the coach.
  /// [trackingNumber] is stored when moving to Shipped.
  static Future<String?> advanceBatchStatus(
    FirebaseFirestore firestore,
    User admin,
    String batchId, {
    String? trackingNumber,
  }) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      final qs = await firestore.collection(FirestorePaths.parentOrders).where('batchId', isEqualTo: batchId).get();
      final docs = qs.docs.where((d) => (d.data()['status'] ?? '') != OrderStatus.cancelled).toList();
      if (docs.isEmpty) return 'Batch not found.';

      final current = docs.first.data()['status'] as String? ?? OrderStatus.submitted;
      final next = OrderStatus.next(current);
      if (next == null) return 'This master order is already ${OrderStatus.label(current)}.';

      final event = StatusEvent(status: next, at: DateTime.now(), by: admin.id).toMap();
      final tracking = trackingNumber?.trim();
      final storeId = docs.first.data()['teamStoreId'] as String?;

      // Firestore batches hold 500 writes; each order needs up to 2.
      for (var i = 0; i < docs.length; i += 200) {
        final chunk = docs.skip(i).take(200);
        final batch = firestore.batch();
        for (final doc in chunk) {
          batch.update(doc.reference, {
            'status': next,
            'statusHistory': FieldValue.arrayUnion([event]),
            if (next == OrderStatus.shipped && tracking != null && tracking.isNotEmpty) 'trackingNumber': tracking,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          NotificationService.addToBatch(
            batch,
            firestore,
            userId: (doc.data()['userId'] as String?) ?? '',
            type: NotificationService.orderStatus,
            title: 'Order ${OrderStatus.label(next).toLowerCase()}',
            message: 'The order for ${doc.data()['athleteFirstName'] ?? 'your athlete'} is now ${OrderStatus.label(next)}.',
            data: {'orderId': doc.id, 'batchId': batchId},
          );
        }
        await batch.commit();
      }

      if (storeId != null) {
        final storeDoc = await firestore.collection(FirestorePaths.teamStores).doc(storeId).get();
        final ownerId = storeDoc.data()?['userId'] as String?;
        if (ownerId != null) {
          await NotificationService.send(
            firestore,
            userId: ownerId,
            type: NotificationService.batchStatus,
            title: 'Master order ${OrderStatus.label(next).toLowerCase()}',
            message: 'Your master order is now ${OrderStatus.label(next)}.',
            data: {'batchId': batchId, 'storeId': storeId},
          );
        }
      }
    } catch (e) {
      return 'Could not update the master order. ${_friendly(e)}';
    }
    return null;
  }

  static String _friendly(Object e) =>
      e is FirebaseException && e.code == 'permission-denied' ? 'You do not have permission to do that.' : 'Please try again.';


  static String? markQuoteAddressed(User admin, String quoteId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }
}
