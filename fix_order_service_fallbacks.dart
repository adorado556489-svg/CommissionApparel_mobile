import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Fix finalizeDirectOrders
  content = content.replaceFirst(
'''      try {
        final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: currentUser.id).where('status', isEqualTo: 'Draft').get();
        draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      } catch (_) {
        draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
      }''',
'''      try {
        final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: currentUser.id).where('status', isEqualTo: 'Draft').get();
        if (qs.docs.isEmpty) {
          draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
        } else {
          draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
        }
      } catch (_) {
        draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
      }'''
  );

  // Fix submitStoreOrdersToAdmin
  content = content.replaceFirst(
'''      List<ParentOrder> unbatched = [];
      try {
        final qs = await firestore.collection(_collectionPath).where('teamStoreId', isEqualTo: storeId).where('batchId', isNull: true).get();
        unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      } catch (_) {
        unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
      }''',
'''      List<ParentOrder> unbatched = [];
      try {
        final qs = await firestore.collection(_collectionPath).where('teamStoreId', isEqualTo: storeId).where('batchId', isNull: true).get();
        if (qs.docs.isEmpty) {
          unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
        } else {
          unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
        }
      } catch (_) {
        unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
      }'''
  );

  // Fix archiveDirectOrderBatch
  content = content.replaceFirst(
'''      List<ParentOrder> batched = [];
      try {
        final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: currentUser.id).where('batchId', isEqualTo: batchId).where('isArchived', isEqualTo: false).get();
        batched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
      } catch (_) {
        batched = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.batchId == batchId && !o.isArchived).toList();
      }''',
'''      List<ParentOrder> batched = [];
      try {
        final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: currentUser.id).where('batchId', isEqualTo: batchId).where('isArchived', isEqualTo: false).get();
        if (qs.docs.isEmpty) {
          batched = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.batchId == batchId && !o.isArchived).toList();
        } else {
          batched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
        }
      } catch (_) {
        batched = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.batchId == batchId && !o.isArchived).toList();
      }'''
  );

  // Fix getDirectOrdersForCoach
  content = content.replaceFirst(
'''  static Future<List<ParentOrder>> getDirectOrdersForCoach(FirebaseFirestore firestore, String coachId) async {
    try {
      final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: coachId).get();
      return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coachId).toList();
    }
  }''',
'''  static Future<List<ParentOrder>> getDirectOrdersForCoach(FirebaseFirestore firestore, String coachId) async {
    try {
      final qs = await firestore.collection(_collectionPath).where('teamStoreId', isNull: true).where('userId', isEqualTo: coachId).get();
      if (qs.docs.isEmpty) {
        return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coachId).toList();
      }
      return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();
    } catch (_) {
      return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coachId).toList();
    }
  }'''
  );

  file.writeAsStringSync(content);
}
