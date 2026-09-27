import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final methods = '''
  static Stream<List<ParentOrder>> getUnbatchedOrdersForStoreStream(FirebaseFirestore firestore, String storeId) {
    return firestore
        .collection(_collectionPath)
        .where('teamStoreId', isEqualTo: storeId)
        .where('batchId', isNull: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return dummyParentOrders
            .where((o) => o.teamStoreId == storeId && o.batchId == null)
            .toList();
      }
      return snapshot.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    });
  }

  static Future<List<ParentOrder>> getDirectOrdersForCoach(FirebaseFirestore firestore, String coachId) async {
    try {
      final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: coachId).get();
      if (qs.docs.isEmpty) {
        return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coachId).toList();
      }
      return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coachId).toList();
    }
  }

  static Future<List<ParentOrder>> getSubmittedOrders(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(_collectionPath).where('status', isEqualTo: 'Submitted to Admin').get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (_) {}
    return dummyParentOrders.where((o) => o.status == 'Submitted to Admin').toList();
  }

  static Future<List<ParentOrder>> getOrdersForBatch(FirebaseFirestore firestore, String batchId) async {
    try {
      final qs = await firestore.collection(_collectionPath).where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      }
    } catch (_) {}
    return dummyParentOrders.where((o) => o.batchId == batchId).toList();
  }
}
''';

  content = content.replaceFirst(RegExp(r'\}\s*$'), methods);
  file.writeAsStringSync(content);
}
