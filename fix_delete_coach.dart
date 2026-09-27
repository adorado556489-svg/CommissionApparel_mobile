import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("""  static Future<String?> deleteCoach(FirebaseFirestore firestore, User admin, String coachId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    

    
    
    return null;
  }""", """  static Future<String?> deleteCoach(FirebaseFirestore firestore, User admin, String coachId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    final qsStores = await firestore.collection(FirestorePaths.teamStores).where('coachId', isEqualTo: coachId).get();
    final batch = firestore.batch();
    for (var doc in qsStores.docs) {
      final qsOrders = await firestore.collection(FirestorePaths.parentOrders).where('teamStoreId', isEqualTo: doc.id).get();
      for (var oDoc in qsOrders.docs) {
         batch.delete(oDoc.reference);
      }
      batch.delete(doc.reference);
    }
    batch.delete(firestore.collection(FirestorePaths.users).doc(coachId));
    await batch.commit();

    final storeIds = dummyTeamStores.where((s) => s.coachId == coachId).map((s) => s.id).toList();
    dummyParentOrders.removeWhere((o) => o.teamStoreId != null && storeIds.contains(o.teamStoreId));
    dummyTeamStores.removeWhere((s) => s.coachId == coachId);
    dummyUsers.removeWhere((u) => u.id == coachId);
    
    return null;
  }""");
  file.writeAsStringSync(content);
}
