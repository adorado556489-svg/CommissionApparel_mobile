import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  var newBlock = '''
  static Future<String?> deleteCoach(FirebaseFirestore firestore, User admin, String coachId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final batch = firestore.batch();
      final directOrders = await firestore.collection(FirestorePaths.parentOrders).where('userId', isEqualTo: coachId).where('teamStoreId', isNull: true).get();
      for (var doc in directOrders.docs) { batch.delete(doc.reference); }
      
      final stores = await firestore.collection('teamStores').where('userId', isEqualTo: coachId).get();
      for (var storeDoc in stores.docs) {
        final storeOrders = await firestore.collection(FirestorePaths.parentOrders).where('teamStoreId', isEqualTo: storeDoc.id).get();
        for (var doc in storeOrders.docs) { batch.delete(doc.reference); }
        batch.delete(storeDoc.reference);
      }
      batch.delete(firestore.collection('users').doc(coachId));
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code != 'not-found' && e.code != 'unimplemented') {
        print('CRITICAL FIRESTORE ERROR [AdminService.deleteCoach]: \${e.message}');
        throw e;
      }
    }
    
    final index = dummyUsers.indexWhere((u) => u.id == coachId);
    if (index != -1) {
      final coachStoreIds = dummyTeamStores.where((s) => s.userId == coachId).map((s) => s.id).toSet();
      dummyParentOrders.removeWhere((o) => o.teamStoreId != null && coachStoreIds.contains(o.teamStoreId));
      dummyParentOrders.removeWhere((o) => o.teamStoreId == null && o.userId == coachId);
      dummyTeamStores.removeWhere((s) => s.userId == coachId);
      dummyUsers.removeAt(index);
    }
    
    return null;
  }

  // --- BATCH MANAGEMENT ---
''';
  
  content = content.replaceFirst('  // --- BATCH MANAGEMENT ---', newBlock);
  file.writeAsStringSync(content);
}
