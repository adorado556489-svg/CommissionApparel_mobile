import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // getUnbatchedOrdersForStoreStream
  final getUnbatchedStream = '''  static Stream<List<ParentOrder>> getUnbatchedOrdersForStoreStream(FirebaseFirestore firestore, String storeId) {
    return firestore
        .collection(_collectionPath)
        .where('teamStoreId', isEqualTo: storeId)
        .where('batchId', isNull: true)
        .snapshots()
        .map((qs) {
          if (qs.docs.isEmpty) {
            return dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
          }
          return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
        });
  }

  static Future<List<ParentOrder>> getOrdersForBatch''';
  
  if (!content.contains('getUnbatchedOrdersForStoreStream')) {
    content = content.replaceFirst('  static Future<List<ParentOrder>> getOrdersForBatch', getUnbatchedStream);
  }
  
  // replace getAllOrders with getSubmittedOrders in the admin dashboard (Wait, Admin uses OrderService.getSubmittedOrders but we didn't add it to order_service.dart yet because the first replace failed!)
  final getSubmitted = '''  static Future<List<ParentOrder>> getSubmittedOrders(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore
          .collection(_collectionPath)
          .where('status', isEqualTo: 'Submitted')
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'OrderService.getSubmittedOrders');
    }
    return dummyParentOrders.where((o) => o.status == 'Submitted').toList();
  }

  static Future<List<ParentOrder>> getAllOrders''';
  if (!content.contains('getSubmittedOrders')) {
    content = content.replaceFirst('  static Future<List<ParentOrder>> getAllOrders', getSubmitted);
  }

  content = content.replaceAll(
    'List<ParentOrder> allOrders = await getAllOrders(firestore);\n    final unbatched = allOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();',
    '''List<ParentOrder> unbatched = [];
    try {
      final qs = await firestore.collection(_collectionPath).where('teamStoreId', isEqualTo: storeId).where('batchId', isNull: true).get();
      unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
    }'''
  );

  content = content.replaceAll(
    'List<ParentOrder> allOrders = await getAllOrders(firestore);\n    final draftOrders = allOrders.where(\n      (o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == \'Draft\'\n    ).toList();',
    '''List<ParentOrder> draftOrders = [];
    try {
      final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: currentUser.id).where('status', isEqualTo: 'Draft').get();
      draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
    }'''
  );
  
  content = content.replaceAll(
    'List<ParentOrder> allOrders = await getAllOrders(firestore);\n    final batchOrders = allOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();',
    '''List<ParentOrder> batchOrders = [];
    try {
      final qs = await firestore.collection(_collectionPath).where('userId', isEqualTo: currentUser.id).where('batchId', isEqualTo: batchId).get();
      batchOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      batchOrders = dummyParentOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();
    }'''
  );
  
  content = content.replaceAll(
    'List<ParentOrder> allOrders = await getAllOrders(firestore);\n    final existingIndex = allOrders.indexWhere((o) => o.id == updatedOrder.id);\n    if (existingIndex == -1) return \'Order not found\';\n    final existingOrder = allOrders[existingIndex];',
    '''ParentOrder? existingOrder;
    try {
      final doc = await firestore.collection(_collectionPath).doc(updatedOrder.id).get();
      if (doc.exists) existingOrder = ParentOrder.fromFirestore(doc);
    } catch (_) {
      try { existingOrder = dummyParentOrders.firstWhere((o) => o.id == updatedOrder.id); } catch (_) {}
    }
    if (existingOrder == null) return 'Order not found';'''
  );
  
  content = content.replaceAll(
    'List<ParentOrder> allOrders = await getAllOrders(firestore);\n    final index = allOrders.indexWhere((o) => o.id == orderId);\n    if (index == -1) return \'Order not found\';\n    final order = allOrders[index];',
    '''ParentOrder? order;
    try {
      final doc = await firestore.collection(_collectionPath).doc(orderId).get();
      if (doc.exists) order = ParentOrder.fromFirestore(doc);
    } catch (_) {
      try { order = dummyParentOrders.firstWhere((o) => o.id == orderId); } catch (_) {}
    }
    if (order == null) return 'Order not found';'''
  );

  file.writeAsStringSync(content);
}
