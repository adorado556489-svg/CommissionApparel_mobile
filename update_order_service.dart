import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
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
  
  content = content.replaceFirst('static Future<List<ParentOrder>> getAllOrders', getSubmitted);
  
  // Also add getUnbatchedOrdersForStoreStream
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
  
  content = content.replaceFirst('static Future<List<ParentOrder>> getOrdersForBatch', getUnbatchedStream);
  
  // Also optimize submitStoreOrdersToAdmin
  final submitStoreOld = '''  static Future<void> submitStoreOrdersToAdmin(FirebaseFirestore firestore, User currentUser, String storeId, String batchId) async {
    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final unbatched = allOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();''';
  final submitStoreNew = '''  static Future<void> submitStoreOrdersToAdmin(FirebaseFirestore firestore, User currentUser, String storeId, String batchId) async {
    List<ParentOrder> unbatched = [];
    try {
      final qs = await firestore.collection(_collectionPath).where('teamStoreId', isEqualTo: storeId).where('batchId', isNull: true).get();
      unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
    }''';
  content = content.replaceFirst(submitStoreOld, submitStoreNew);
  
  // finalizeDirectOrders
  final finalizeDirectOld = '''  static Future<String?> finalizeDirectOrders(FirebaseFirestore firestore, User currentUser) async {
    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final draftOrders = allOrders.where(
      (o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft'
    ).toList();''';
  final finalizeDirectNew = '''  static Future<String?> finalizeDirectOrders(FirebaseFirestore firestore, User currentUser) async {
    List<ParentOrder> draftOrders = [];
    try {
      final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: currentUser.id).where('status', isEqualTo: 'Draft').get();
      draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
    }''';
  content = content.replaceFirst(finalizeDirectOld, finalizeDirectNew);

  // archiveBatch
  final archiveOld = '''  static Future<String?> archiveBatch(FirebaseFirestore firestore, User currentUser, String batchId) async {
    if (currentUser.role != UserRole.coach) return 'Unauthorized';

    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final batchOrders = allOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();''';
  final archiveNew = '''  static Future<String?> archiveBatch(FirebaseFirestore firestore, User currentUser, String batchId) async {
    if (currentUser.role != UserRole.coach) return 'Unauthorized';

    List<ParentOrder> batchOrders = [];
    try {
      final qs = await firestore.collection(_collectionPath).where('userId', isEqualTo: currentUser.id).where('batchId', isEqualTo: batchId).get();
      batchOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      batchOrders = dummyParentOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();
    }''';
  content = content.replaceFirst(archiveOld, archiveNew);
  
  // updateOrder
  final updateOld = '''  static Future<String?> updateOrder(FirebaseFirestore firestore, User currentUser, ParentOrder updatedOrder) async {
    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final existingIndex = allOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (existingIndex == -1) return 'Order not found';
    final existingOrder = allOrders[existingIndex];''';
  final updateNew = '''  static Future<String?> updateOrder(FirebaseFirestore firestore, User currentUser, ParentOrder updatedOrder) async {
    ParentOrder? existingOrder;
    try {
      final doc = await firestore.collection(_collectionPath).doc(updatedOrder.id).get();
      if (doc.exists) existingOrder = ParentOrder.fromFirestore(doc);
    } catch (_) {
      try { existingOrder = dummyParentOrders.firstWhere((o) => o.id == updatedOrder.id); } catch (_) {}
    }
    if (existingOrder == null) return 'Order not found';''';
  content = content.replaceFirst(updateOld, updateNew);
  
  // deleteOrder
  final deleteOld = '''  static Future<String?> deleteOrder(FirebaseFirestore firestore, User currentUser, String orderId) async {
    List<ParentOrder> allOrders = await getAllOrders(firestore);
    final index = allOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return 'Order not found';
    final order = allOrders[index];''';
  final deleteNew = '''  static Future<String?> deleteOrder(FirebaseFirestore firestore, User currentUser, String orderId) async {
    ParentOrder? order;
    try {
      final doc = await firestore.collection(_collectionPath).doc(orderId).get();
      if (doc.exists) order = ParentOrder.fromFirestore(doc);
    } catch (_) {
      try { order = dummyParentOrders.firstWhere((o) => o.id == orderId); } catch (_) {}
    }
    if (order == null) return 'Order not found';''';
  content = content.replaceFirst(deleteOld, deleteNew);
  
  file.writeAsStringSync(content);
}
