import 'dart:io';

void main() {
  var file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('getOrdersForUser')) {
    var injection = """
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
""";
    content = content.replaceFirst(
      "static Future<List<ParentOrder>> getAllOrders(FirebaseFirestore firestore) async {",
      injection + "\n  static Future<List<ParentOrder>> getAllOrders(FirebaseFirestore firestore) async {"
    );
  }
  
  if (!content.contains('getUnbatchedOrdersForStoreStream')) {
    var injection2 = """
  static Stream<List<ParentOrder>> getUnbatchedOrdersForStoreStream(FirebaseFirestore firestore, String storeId) {
    return firestore
        .collection(_collectionPath)
        .where('teamStoreId', isEqualTo: storeId)
        .where('batchId', isNull: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList());
  }
""";
    content = content.replaceFirst(
      "static Future<List<ParentOrder>> getAllOrders",
      injection2 + "\n  static Future<List<ParentOrder>> getAllOrders"
    );
  }
  
  file.writeAsStringSync(content);
  print('OrderService updated');
}
