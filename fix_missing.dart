import 'dart:io';

void main() {
  // 1. StoreService
  var storeLines = File('lib/services/store_service.dart').readAsLinesSync();
  var getPendingStoresStream = """
  static Stream<List<TeamStore>> getPendingStoresStream(FirebaseFirestore firestore) {
    return firestore
        .collection(FirestorePaths.teamStores)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((qs) => qs.docs.map((d) => TeamStore.fromFirestore(d)).toList());
  }
""";
  storeLines.insert(storeLines.length - 1, getPendingStoresStream);
  File('lib/services/store_service.dart').writeAsStringSync(storeLines.join('\n'));

  // 2. OrderService
  var orderLines = File('lib/services/order_service.dart').readAsLinesSync();
  var orderMethods = """
  static Future<ParentOrder?> getOrderById(FirebaseFirestore firestore, String id) async {
    try {
      var doc = await firestore.collection(FirestorePaths.parentOrders).doc(id).get();
      if (doc.exists) return ParentOrder.fromFirestore(doc);
    } catch (e) {
      _handleError(e, 'OrderService.getOrderById');
    }
    return null;
  }

  static Stream<List<ParentOrder>> getUnbatchedOrdersForStoreStream(FirebaseFirestore firestore, String storeId) {
    return firestore
        .collection(FirestorePaths.parentOrders)
        .where('teamStoreId', isEqualTo: storeId)
        .where('batchId', isNull: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList());
  }

  static Future<List<ParentOrder>> getOrdersForBatch(FirebaseFirestore firestore, String batchId) async {
    try {
      var qs = await firestore.collection(FirestorePaths.parentOrders).where('batchId', isEqualTo: batchId).get();
      return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, 'OrderService.getOrdersForBatch');
    }
    return [];
  }

  static Future<List<ParentOrder>> getDirectOrdersForCoach(FirebaseFirestore firestore, String coachId) async {
    try {
      var qs = await firestore.collection(FirestorePaths.parentOrders).where('userId', isEqualTo: coachId).where('teamStoreId', isNull: true).get();
      return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, 'OrderService.getDirectOrdersForCoach');
    }
    return [];
  }

  static Future<List<ParentOrder>> getSubmittedOrders(FirebaseFirestore firestore) async {
    try {
      var qs = await firestore.collection(FirestorePaths.parentOrders).where('status', isEqualTo: 'Submitted to Admin').get();
      return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, 'OrderService.getSubmittedOrders');
    }
    return [];
  }
""";
  orderLines.insert(orderLines.length - 1, orderMethods);
  File('lib/services/order_service.dart').writeAsStringSync(orderLines.join('\n'));

  // 3. CatalogService
  var catalogLines = File('lib/services/catalog_service.dart').readAsLinesSync();
  var catalogMethods = """
  static Future<DesignCatalog?> getDesignById(FirebaseFirestore firestore, String id) async {
    try {
      var doc = await firestore.collection(FirestorePaths.designCatalog).doc(id).get();
      if (doc.exists) return DesignCatalog.fromFirestore(doc);
    } catch (e) {
      _handleError(e, 'CatalogService.getDesignById');
    }
    return null;
  }
""";
  catalogLines.insert(catalogLines.length - 1, catalogMethods);
  File('lib/services/catalog_service.dart').writeAsStringSync(catalogLines.join('\n'));

  // 4. AuthService
  var authLines = File('lib/services/auth_service.dart').readAsLinesSync();
  var authMethods = """
  Future<User?> getUserById(String id) async {
    try {
      var doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) return User.fromFirestore(doc);
    } catch (e) {}
    return null;
  }

  Future<List<User>> getAllCoaches() async {
    try {
      var qs = await _firestore.collection('users').where('role', isEqualTo: 'coach').get();
      return qs.docs.map((d) => User.fromFirestore(d)).toList();
    } catch (e) {}
    return [];
  }
""";
  authLines.insert(authLines.length - 1, authMethods);
  File('lib/services/auth_service.dart').writeAsStringSync(authLines.join('\n'));
}
