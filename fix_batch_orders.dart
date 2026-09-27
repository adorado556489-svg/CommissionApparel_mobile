import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  // markDirectBatchAddressed
  content = content.replaceFirst('''
      final qs = await firestore.collection(FirestorePaths.parentOrders).where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          if (doc.data()['teamStoreId'] == null) {
            batch.update(doc.reference, {'status': 'Processing', 'isArchived': true});
          }
        }
        await batch.commit();
      }
''', '''
      var qs = await firestore.collection(FirestorePaths.parentOrders).where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isEmpty) { qs = await firestore.collection('orders').where('batchId', isEqualTo: batchId).get(); }
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          if (doc.data()['teamStoreId'] == null) {
            batch.update(doc.reference, {'status': 'Processing', 'isArchived': true});
          }
        }
        await batch.commit();
      }
''');

  // markStoreBatchAddressed
  content = content.replaceFirst('''
      final qs = await firestore.collection(FirestorePaths.parentOrders).where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          if (doc.data()['teamStoreId'] != null) {
            batch.update(doc.reference, {'status': 'Processing', 'isArchived': true});
          }
        }
        await batch.commit();
      }
''', '''
      var qs = await firestore.collection(FirestorePaths.parentOrders).where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isEmpty) { qs = await firestore.collection('orders').where('batchId', isEqualTo: batchId).get(); }
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          if (doc.data()['teamStoreId'] != null) {
            batch.update(doc.reference, {'status': 'Processing', 'isArchived': true});
          }
        }
        await batch.commit();
      }
''');

  // deleteArchivedOrderBatch
  content = content.replaceFirst('''
      final qs = await firestore.collection(FirestorePaths.parentOrders).where('batchId', isEqualTo: batchId).where('isArchived', isEqualTo: true).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
''', '''
      var qs = await firestore.collection(FirestorePaths.parentOrders).where('batchId', isEqualTo: batchId).where('isArchived', isEqualTo: true).get();
      if (qs.docs.isEmpty) { qs = await firestore.collection('orders').where('batchId', isEqualTo: batchId).where('isArchived', isEqualTo: true).get(); }
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
''');

  file.writeAsStringSync(content);
}
