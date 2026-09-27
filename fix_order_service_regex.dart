import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // I will just use robust regex to fix these functions

  // 1. finalizeDirectOrders
  content = content.replaceFirst(
    RegExp(r"      try \{\n        final qs = await firestore\.collection\(_collectionPath\)\.where\('teamStoreId', isNull: true\)\.where\('userId', isEqualTo: currentUser\.id\)\.where\('status', isEqualTo: 'Draft'\)\.get\(\);\n        draftOrders = qs\.docs\.map\(\(d\) => ParentOrder\.fromFirestore\((d)\)\)\.toList\(\);\n      \} catch \(_\) \{\n        draftOrders = dummyParentOrders\.where\(\(o\) => o\.teamStoreId == null && o\.userId == currentUser\.id && o\.status == 'Draft'\)\.toList\(\);\n      \}"),
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

  // 2. submitStoreOrdersToAdmin
  content = content.replaceFirst(
    RegExp(r"      try \{\n        final qs = await firestore\.collection\(_collectionPath\)\.where\('teamStoreId', isEqualTo: storeId\)\.where\('batchId', isNull: true\)\.get\(\);\n        unbatched = qs\.docs\.map\(\(d\) => ParentOrder\.fromFirestore\((d)\)\)\.toList\(\);\n      \} catch \(_\) \{\n        unbatched = dummyParentOrders\.where\(\(o\) => o\.teamStoreId == storeId && o\.batchId == null\)\.toList\(\);\n      \}"),
    '''      try {
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

  // 3. archiveDirectOrderBatch
  content = content.replaceFirst(
    RegExp(r"      try \{\n        final qs = await firestore\.collection\(_collectionPath\)\.where\('teamStoreId', isNull: true\)\.where\('userId', isEqualTo: currentUser\.id\)\.where\('batchId', isEqualTo: batchId\)\.where\('isArchived', isEqualTo: false\)\.get\(\);\n        batched = qs\.docs\.map\(\(d\) => ParentOrder\.fromFirestore\((d)\)\)\.toList\(\);\n      \} catch \(_\) \{\n        batched = dummyParentOrders\.where\(\(o\) => o\.teamStoreId == null && o\.userId == currentUser\.id && o\.batchId == batchId && !o\.isArchived\)\.toList\(\);\n      \}"),
    '''      try {
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

  // 4. getDirectOrdersForCoach
  content = content.replaceFirst(
    RegExp(r"  static Future<List<ParentOrder>> getDirectOrdersForCoach\(FirebaseFirestore firestore, String coachId\) async \{\n    try \{\n      final qs = await firestore\.collection\(_collectionPath\)\.where\('teamStoreId', isNull: true\)\.where\('userId', isEqualTo: coachId\)\.get\(\);\n      return qs\.docs\.map\(\(d\) => ParentOrder\.fromFirestore\((d)\)\)\.toList\(\);\n    \} catch \(_\) \{\n      return dummyParentOrders\.where\(\(o\) => o\.teamStoreId == null && o\.userId == coachId\)\.toList\(\);\n    \}\n  \}"),
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
