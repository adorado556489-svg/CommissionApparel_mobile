import 'dart:io';

void main() {
  var file = File('test/admin_batch_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("firestore.collection('parentOrders')", "firestore.collection('orders')");
  content = content.replaceAll("dummyParentOrders.add", "// dummyParentOrders.add");
  content = content.replaceAll("final updatedOrder = dummyParentOrders.firstWhere", "final doc = await firestore.collection('orders').doc(order.id).get(); final updatedOrder = ParentOrder.fromFirestore(doc); // dummy");
  content = content.replaceAll("dummyParentOrders.removeWhere", "// dummyParentOrders.removeWhere");
  
  // also deleteArchivedOrderBatch needs to read from firestore
  content = content.replaceAll("final orderCheck = dummyParentOrders.indexWhere((o) => o.id == 'store-archived-123');\n      expect(orderCheck, -1);", "final doc2 = await firestore.collection('orders').doc('store-archived-123').get(); expect(doc2.exists, isFalse);");
  
  // fix setUp() assigning firestore = firestore
  content = content.replaceFirst("firestore = firestore;", "firestore = FakeFirebaseFirestore();");
  
  file.writeAsStringSync(content);
}
