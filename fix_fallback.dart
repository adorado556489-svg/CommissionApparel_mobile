import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceAll(
    '''    try {
      final doc = await firestore.collection(_collectionPath).doc(orderId).get();
      if (doc.exists) order = ParentOrder.fromFirestore(doc);
    } catch (_) {
      try { order = dummyParentOrders.firstWhere((o) => o.id == orderId); } catch (_) {}
    }''',
    '''    try {
      final doc = await firestore.collection(_collectionPath).doc(orderId).get();
      if (doc.exists) {
        order = ParentOrder.fromFirestore(doc);
      } else {
        order = dummyParentOrders.firstWhere((o) => o.id == orderId);
      }
    } catch (_) {
      try { order = dummyParentOrders.firstWhere((o) => o.id == orderId); } catch (_) {}
    }'''
  );

  content = content.replaceAll(
    '''    try {
      final doc = await firestore.collection(_collectionPath).doc(updatedOrder.id).get();
      if (doc.exists) existingOrder = ParentOrder.fromFirestore(doc);
    } catch (_) {
      try { existingOrder = dummyParentOrders.firstWhere((o) => o.id == updatedOrder.id); } catch (_) {}
    }''',
    '''    try {
      final doc = await firestore.collection(_collectionPath).doc(updatedOrder.id).get();
      if (doc.exists) {
        existingOrder = ParentOrder.fromFirestore(doc);
      } else {
        existingOrder = dummyParentOrders.firstWhere((o) => o.id == updatedOrder.id);
      }
    } catch (_) {
      try { existingOrder = dummyParentOrders.firstWhere((o) => o.id == updatedOrder.id); } catch (_) {}
    }'''
  );

  file.writeAsStringSync(content);
}
