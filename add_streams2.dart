import 'dart:io';

void main() {
  var file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  if (!content.contains('getUnbatchedOrdersForStoreStream')) {
    content = content.replaceFirst('class OrderService {', '''class OrderService {
  static Stream<List<ParentOrder>> getUnbatchedOrdersForStoreStream(FirebaseFirestore firestore, String storeId) {
    return firestore.collection('orders').where('teamStoreId', isEqualTo: storeId).where('batchId', isNull: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ParentOrder.fromFirestore(doc)).toList();
    });
  }
''');
    file.writeAsStringSync(content);
  }
}
