import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_order.dart';
import '../models/user.dart';
import '../constants/firestore_paths.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  static Future<List<ParentOrder>> getOrdersForStore(dynamic firestore, String storeId) async { return []; }

  static Stream<List<ParentOrder>> getUnbatchedOrdersForStoreStream(dynamic firestore, String storeId) {
    return firestore.collection('parentOrders').where('teamStoreId', isEqualTo: storeId).where('status', isEqualTo: 'pending').snapshots().map((snapshot) => snapshot.docs.map((doc) => ParentOrder.fromFirestore(doc as DocumentSnapshot)).cast<ParentOrder>().toList());
  }

  static const String _collectionPath = FirestorePaths.parentOrders;
  static const String _storeCollectionPath = FirestorePaths.teamStores;

  static void _handleError(Object e, String context) {
    if (e is FirebaseException && (e.code == 'not-found' || e.code == 'unimplemented')) return;
    debugPrint('CRITICAL FIRESTORE ERROR [$context]: $e');
  }

  static Future<List<ParentOrder>> getOrdersForUser(FirebaseFirestore firestore, String userId) async {
    try {
      final qs = await firestore.collection(_collectionPath)
          .where('userId', isEqualTo: userId)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'OrderService.getOrdersForUser');
      rethrow;
    }
    return [];
  }

  static Future<List<ParentOrder>> getUnbatchedOrdersForStore(FirebaseFirestore firestore, String storeId) async {
    try {
      final qs = await firestore.collection(_collectionPath)
          .where('teamStoreId', isEqualTo: storeId)
          .where('batchId', isNull: true)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'OrderService.getUnbatchedOrdersForStore');
      rethrow;
    }
    return [];
  }

  static Future<List<ParentOrder>> getOrdersForBatch(FirebaseFirestore firestore, String batchId) async {
    try {
      final qs = await firestore.collection(_collectionPath)
          .where('batchId', isEqualTo: batchId)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'OrderService.getOrdersForBatch');
      rethrow;
    }
    return [];
  }

  static Future<List<ParentOrder>> getSubmittedBatchedOrders(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(_collectionPath)
          .where('status', isEqualTo: 'Submitted to Admin')
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'OrderService.getSubmittedBatchedOrders');
      rethrow;
    }
    return [];
  }

  static Future<ParentOrder?> getOrderById(FirebaseFirestore firestore, String orderId) async {
    try {
      final doc = await firestore.collection(_collectionPath).doc(orderId).get();
      if (doc.exists) {
        return ParentOrder.fromFirestore(doc);
      }
    } catch (e) {
      _handleError(e, 'OrderService.getOrderById');
      rethrow;
    }
    return null;
  }

  static Future<bool> _isAuthorizedForStore(FirebaseFirestore firestore, User currentUser, String storeId) async {
    if (currentUser.role == UserRole.admin) return true;
    try {
      final doc = await firestore.collection(_storeCollectionPath).doc(storeId).get();
      if (doc.exists) {
        return doc.data()?['userId'] == currentUser.id;
      }
    } catch (e) {
      _handleError(e, 'OrderService._isAuthorizedForStore');
    }
    return false;
  }

  static Future<void> createOrder(FirebaseFirestore firestore, ParentOrder order) async {
    try {
      await firestore.collection(_collectionPath).doc(order.id).set(order.toFirestore());
    } catch (e) {
      _handleError(e, 'OrderService.createOrder');
      rethrow;
    }
  }

  static Future<String?> submitDirectOrder(
    FirebaseFirestore firestore,
    User currentUser, {
    required String orderType,
    String? athleteFirstName,
    String? athleteLastName,
    String? gender,
    String? jerseyName,
    String? jerseyNumber,
    String? backpackName,
    required List<OrderItemEntry> items,
  }) async {
    if (items.isEmpty) {
      return 'Please select at least one item before submitting.';
    }

    final firstName = orderType == 'item' ? 'Bulk' : (athleteFirstName ?? 'Direct');
    final lastName = orderType == 'item' ? 'Order' : (athleteLastName ?? 'Order');

    final newId = DateTime.now().millisecondsSinceEpoch.toString() + '_' + currentUser.id;
    final newOrder = ParentOrder(
      id: newId,
      teamStoreId: null,
      userId: currentUser.id,
      athleteFirstName: firstName,
      athleteLastName: lastName,
      gender: gender,
      jerseyName: jerseyName,
      jerseyNumber: jerseyNumber,
      backpackName: backpackName,
      itemEntries: items,
      totalRetailPrice: 0.0,
      status: 'Draft',
      isEdited: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await firestore.collection(_collectionPath).doc(newId).set(newOrder.toFirestore());
    } catch (e) {
      _handleError(e, 'OrderService.submitDirectOrder');
      return e.toString();
    }
    return null;
  }

  static Future<String?> submitStoreOrdersToAdmin(FirebaseFirestore firestore, User currentUser, String storeId, String batchId) async {
    final isAuthorized = await _isAuthorizedForStore(firestore, currentUser, storeId);
    if (!isAuthorized) return 'Unauthorized';

    List<ParentOrder> unbatched = [];
    try {
      final qs = await firestore.collection(_collectionPath)
          .where('teamStoreId', isEqualTo: storeId)
          .where('batchId', isNull: true)
          .get();
      unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, 'OrderService.submitStoreOrdersToAdmin');
      return e.toString();
    }
    
    try {
      final batch = firestore.batch();
      for (var o in unbatched) {
        final ref = firestore.collection(_collectionPath).doc(o.id);
        batch.update(ref, {
          'status': 'Submitted to Admin',
          'batchId': batchId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      _handleError(e, 'OrderService.submitStoreOrdersToAdmin');
      return e.toString();
    }
    return null;
  }

  static Future<String?> finalizeDirectOrders(FirebaseFirestore firestore, User currentUser) async {
    List<ParentOrder> draftOrders = [];
    try {
      final qs = await firestore.collection(_collectionPath)
          .where('userId', isEqualTo: currentUser.id)
          .get();
      draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d))
          .where((o) => o.teamStoreId == null && o.status == 'Draft').toList();
    } catch (e) {
      _handleError(e, 'OrderService.finalizeDirectOrders');
      return e.toString();
    }

    if (draftOrders.isEmpty) {
      return 'You have no draft orders to submit.';
    }

    final batchId = DateTime.now().millisecondsSinceEpoch.toString() + '_' + currentUser.id;

    try {
      final batch = firestore.batch();
      for (var o in draftOrders) {
        final ref = firestore.collection(_collectionPath).doc(o.id);
        batch.update(ref, {
          'status': 'Submitted to Admin',
          'batchId': batchId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      _handleError(e, 'OrderService.finalizeDirectOrders');
      return e.toString();
    }
    return null; 
  }

  static Future<String?> archiveDirectOrderBatch(FirebaseFirestore firestore, User currentUser, String batchId) async {
    if (currentUser.role != UserRole.coach) return 'Unauthorized';

    List<ParentOrder> batchOrders = [];
    try {
      final qs = await firestore.collection(_collectionPath)
          .where('userId', isEqualTo: currentUser.id)
          .get();
      batchOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d))
          .where((o) => o.batchId == batchId).toList();
    } catch (e) {
      _handleError(e, 'OrderService.archiveDirectOrderBatch');
      return e.toString();
    }

    try {
      final batch = firestore.batch();
      for (var o in batchOrders) {
        final ref = firestore.collection(_collectionPath).doc(o.id);
        batch.update(ref, {
          'isArchived': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      _handleError(e, 'OrderService.archiveDirectOrderBatch');
      return e.toString();
    }
    return null;
  }

  static Future<String?> deleteOrder(FirebaseFirestore firestore, User currentUser, String orderId) async {
    final order = await getOrderById(firestore, orderId);
    if (order == null) return 'Order not found';

    if (currentUser.role != UserRole.admin) {
      if (order.teamStoreId != null) {
        final auth = await _isAuthorizedForStore(firestore, currentUser, order.teamStoreId!);
        if (!auth) return 'Unauthorized';
      } else {
        if (order.userId != currentUser.id) return 'Unauthorized';
      }
    }

    try {
      await firestore.collection(_collectionPath).doc(orderId).delete();
    } catch (e) {
      _handleError(e, 'OrderService.deleteOrder');
      return e.toString();
    }
    return null;
  }

  static Future<String?> updateOrder(FirebaseFirestore firestore, User currentUser, ParentOrder updatedOrder) async {
    final existingOrder = await getOrderById(firestore, updatedOrder.id);
    if (existingOrder == null) return 'Order not found';

    if (currentUser.role != UserRole.admin) {
      if (existingOrder.teamStoreId != null) {
        final ownsStore = await _isAuthorizedForStore(firestore, currentUser, existingOrder.teamStoreId!);
        if (!ownsStore && existingOrder.userId != currentUser.id) return 'Unauthorized';
      } else {
        if (existingOrder.userId != currentUser.id) return 'Unauthorized';
      }
    }

    final newOrder = updatedOrder.copyWith(
      isEdited: true,
      editedBy: currentUser.id,
      updatedAt: DateTime.now(),
    );

    try {
      final data = newOrder.toFirestore();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection(_collectionPath).doc(newOrder.id).update(data);
    } catch (e) {
      _handleError(e, 'OrderService.updateOrder');
      return e.toString();
    }
    return null;
  }
}
