import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final newFinalize = '''  static Future<String?> finalizeDirectOrders(FirebaseFirestore firestore, User currentUser) async {
    List<ParentOrder> draftOrders = [];
    try {
      final qs = await firestore.collection(_collectionPath)
        .where('teamStoreId', isNull: true)
        .where('userId', isEqualTo: currentUser.id)
        .where('status', isEqualTo: 'Draft')
        .get();
      if (qs.docs.isNotEmpty) {
        draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      } else {
        draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
      }
    } catch (_) {
      draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
    }

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
  }''';

  final oldFinalizePattern = RegExp(r'  static Future<String\?> finalizeDirectOrders\(FirebaseFirestore firestore, User currentUser\) async \{.*?(?=  static Future<String\?> archiveDirectOrderBatch)', dotAll: true);
  content = content.replaceFirst(oldFinalizePattern, newFinalize + '\n\n');

  final newSubmit = '''  static Future<void> submitStoreOrdersToAdmin(FirebaseFirestore firestore, User currentUser, String storeId, String batchId) async {
    List<ParentOrder> unbatched = [];
    try {
      final qs = await firestore.collection(_collectionPath)
        .where('teamStoreId', isEqualTo: storeId)
        .where('batchId', isNull: true)
        .get();
      if (qs.docs.isNotEmpty) {
        unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      } else {
        unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
      }
    } catch (_) {
      unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
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
    }

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.teamStoreId == storeId && o.batchId == null) {
        dummyParentOrders[i] = o.copyWith(status: 'Submitted to Admin', batchId: batchId, updatedAt: DateTime.now());
      }
    }
  }''';

  final oldSubmitPattern = RegExp(r'  static Future<void> submitStoreOrdersToAdmin\(FirebaseFirestore firestore, User currentUser, String storeId, String batchId\) async \{.*?(?=  static Future<String\?> finalizeDirectOrders)', dotAll: true);
  content = content.replaceFirst(oldSubmitPattern, newSubmit + '\n\n');

  final newArchive = '''  static Future<String?> archiveDirectOrderBatch(FirebaseFirestore firestore, User currentUser, String batchId) async {
    if (currentUser.role != UserRole.coach) return 'Unauthorized';

    List<ParentOrder> batchOrders = [];
    try {
      final qs = await firestore.collection(_collectionPath)
        .where('userId', isEqualTo: currentUser.id)
        .where('batchId', isEqualTo: batchId)
        .get();
      if (qs.docs.isNotEmpty) {
        batchOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      } else {
        batchOrders = dummyParentOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();
      }
    } catch (_) {
      batchOrders = dummyParentOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();
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
  }''';

  final oldArchivePattern = RegExp(r'  static Future<String\?> archiveDirectOrderBatch\(FirebaseFirestore firestore, User currentUser, String batchId\) async \{.*?(?=  static Future<String\?> deleteOrder)', dotAll: true);
  content = content.replaceFirst(oldArchivePattern, newArchive + '\n\n');
  
  // Also fix updateOrder and deleteOrder to fallback properly instead of using getAllOrders
  final newDelete = '''  static Future<String?> deleteOrder(FirebaseFirestore firestore, User currentUser, String orderId) async {
    ParentOrder? order = await getOrderById(firestore, orderId);
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
    }

    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == orderId);
    if (dummyIndex != -1) dummyParentOrders.removeAt(dummyIndex);
    return null;
  }''';
  
  final oldDeletePattern = RegExp(r'  static Future<String\?> deleteOrder\(FirebaseFirestore firestore, User currentUser, String orderId\) async \{.*?(?=  static Future<String\?> updateOrder)', dotAll: true);
  content = content.replaceFirst(oldDeletePattern, newDelete + '\n\n');

  final newUpdate = '''  static Future<String?> updateOrder(FirebaseFirestore firestore, User currentUser, ParentOrder updatedOrder) async {
    ParentOrder? existingOrder = await getOrderById(firestore, updatedOrder.id);
    if (existingOrder == null) return 'Order not found';

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
  }''';

  final oldUpdatePattern = RegExp(r'  static Future<String\?> updateOrder\(FirebaseFirestore firestore, User currentUser, ParentOrder updatedOrder\) async \{.*?(?=^\})', dotAll: true, multiLine: true);
  content = content.replaceFirst(oldUpdatePattern, newUpdate + '\n');

  file.writeAsStringSync(content);
}
