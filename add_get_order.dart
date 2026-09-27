import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final getOrderById = '''  static Future<ParentOrder?> getOrderById(FirebaseFirestore firestore, String orderId) async {
    try {
      final doc = await firestore.collection(_collectionPath).doc(orderId).get();
      if (doc.exists) return ParentOrder.fromFirestore(doc);
    } catch (e) {
      _handleError(e, 'OrderService.getOrderById');
    }
    try { return dummyParentOrders.firstWhere((o) => o.id == orderId); } catch (_) { return null; }
  }

''';
  
  if (!content.contains('getOrderById')) {
    content = content.replaceFirst('  static Future<List<ParentOrder>> getSubmittedOrders', getOrderById + '  static Future<List<ParentOrder>> getSubmittedOrders');
  }

  file.writeAsStringSync(content);
}
