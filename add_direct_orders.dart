import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final directOrdersMethod = '''  static Future<List<ParentOrder>> getDirectOrdersForCoach(FirebaseFirestore firestore, String userId) async {
    try {
      final qs = await firestore
          .collection(_collectionPath)
          .where('teamStoreId', isNull: true)
          .where('userId', isEqualTo: userId)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'OrderService.getDirectOrdersForCoach');
    }
    return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == userId).toList();
  }

  static Future<List<ParentOrder>> getAllOrders''';
  
  if (!content.contains('getDirectOrdersForCoach')) {
    content = content.replaceFirst('  static Future<List<ParentOrder>> getAllOrders', directOrdersMethod);
  }

  file.writeAsStringSync(content);
}
