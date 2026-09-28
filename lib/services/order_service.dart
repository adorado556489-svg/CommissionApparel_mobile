import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_order.dart';
import '../models/user.dart';
import '../data/dummy_orders.dart';
import '../data/dummy_stores.dart';

class OrderService {
  static const String _collectionPath = 'parentOrders';
  static const String _storeCollectionPath = 'teamStores';

  static void _handleError(Object e, String contextMessage) {
    if (e is FirebaseException) {
      if (e.code == 'not-found' || e.code == 'unimplemented') {
        return; // Expected missing data
      }
      print('CRITICAL FIRESTORE ERROR [$contextMessage]: [${e.plugin}/${e.code}] ${e.message}');
      throw e;
    }
    throw e;
  }

    static Future<List<ParentOrder>> getOrdersForUser(FirebaseFirestore firestore, String userId) async {
    try {
      final qs = await firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: userId)
          .get();
      return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, 'OrderService.getOrdersForUser');
      return [];
    }
  }

    static Stream<List<ParentOrder>> getUnbatchedOrdersForStoreStream(FirebaseFirestore firestore, String storeId) {
    return firestore
        .collection(_collectionPath)
        .where('teamStoreId', isEqualTo: storeId)
        .where('batchId', isNull: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList());
  }

  static Future<List<ParentOrder>> getAllOrders(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(_collectionPath).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'OrderService.getAllOrders');
    }
    return dummyParentOrders.toList();
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
    final storeIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);
    if (storeIndex != -1) {
      return dummyTeamStores[storeIndex].userId == currentUser.id;
    }
    return false;
  }

  static Future<void> createOrder(FirebaseFirestore firestore, ParentOrder order) async {
    try {
      await firestore.collection(_collectionPath).doc(order.id).set(order.toFirestore());
    } catch (e) {
      _handleError(e, 'OrderService.createOrder');
    }
    dummyParentOrders.add(order); // fallback
  }

  static Future<String?> submitDirectOrder(
    FirebaseFirestore firestore, {
    required User currentUser,
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

    final newId = DateTime.now().millisecondsSinceEpoch.toString() + '_' + dummyParentOrders.length.toString();
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
    }
    dummyParentOrders.add(newOrder);
    return null;
  }

  static Future<void> submitStoreOrdersToAdmin(FirebaseFirestore firestore, User currentUser, String storeId, String batchId) async {
    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final unbatched = allOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
    
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
    }

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.teamStoreId == storeId && o.batchId == null) {
        dummyParentOrders[i] = o.copyWith(status: 'Submitted to Admin', batchId: batchId, updatedAt: DateTime.now());
      }
    }
  }

  static Future<String?> finalizeDirectOrders(FirebaseFirestore firestore, User currentUser) async {
    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final draftOrders = allOrders.where(
      (o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft'
    ).toList();

    if (draftOrders.isEmpty) {
      return 'You have no draft orders to submit.';
    }

    final batchId = DateTime.now().millisecondsSinceEpoch.toString() + '_' + dummyParentOrders.length.toString();

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
    }

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft') {
        dummyParentOrders[i] = o.copyWith(
          status: 'Submitted to Admin',
          batchId: batchId,
          updatedAt: DateTime.now(),
        );
      }
    }

    return null; 
  }

  static Future<String?> archiveDirectOrderBatch(FirebaseFirestore firestore, User currentUser, String batchId) async {
    if (currentUser.role != UserRole.coach) return 'Unauthorized';

    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final batchOrders = allOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();

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
    }

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.userId == currentUser.id && o.batchId == batchId) {
        dummyParentOrders[i] = o.copyWith(
          isArchived: true,
          updatedAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  static Future<String?> deleteOrder(FirebaseFirestore firestore, User currentUser, String orderId) async {
    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final index = allOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return 'Order not found';
    final order = allOrders[index];

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
    }

    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == orderId);
    if (dummyIndex != -1) dummyParentOrders.removeAt(dummyIndex);
    return null;
  }

  static Future<String?> updateOrder(FirebaseFirestore firestore, User currentUser, ParentOrder updatedOrder) async {
    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final existingIndex = allOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (existingIndex == -1) return 'Order not found';
    final existingOrder = allOrders[existingIndex];

    if (existingOrder.teamStoreId == null && existingOrder.userId != currentUser.id && currentUser.role != UserRole.admin) {
      return 'Unauthorized';
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
    }

    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (dummyIndex != -1) {
      dummyParentOrders[dummyIndex] = newOrder;
    }

    return null;
  }
}

