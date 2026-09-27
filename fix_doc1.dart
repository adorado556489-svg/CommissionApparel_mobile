import 'dart:io';

void main() {
  var file = File('test/admin_batch_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("final doc = await firestore.collection('orders').doc(order.id).get();", "final doc1 = await firestore.collection('orders').doc(order.id).get();");
  content = content.replaceAll("ParentOrder.fromFirestore(doc);", "ParentOrder.fromFirestore(doc1);");
  file.writeAsStringSync(content);
}
