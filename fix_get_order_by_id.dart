import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final method = '''
  static Future<ParentOrder?> getOrderById(FirebaseFirestore firestore, String orderId) async {
    try {
      final doc = await firestore.collection(_collectionPath).doc(orderId).get();
      if (doc.exists) {
        return ParentOrder.fromFirestore(doc);
      }
    } catch (_) {}
    try {
      return dummyParentOrders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}
''';

  content = content.replaceFirst(RegExp(r'\}\s*$'), method);
  file.writeAsStringSync(content);
}
