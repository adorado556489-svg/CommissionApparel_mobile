import 'dart:io';

void main() {
  var adminFile = File('lib/services/admin_service.dart');
  var adminContent = adminFile.readAsStringSync();
  
  adminContent = adminContent.replaceAll(
    RegExp(r"id:\s*'hero_subtitle_\$\{[^}]+\}',"),
    "id: _firestore.collection(FirestorePaths.siteSettings).doc().id,"
  );
  adminContent = adminContent.replaceAll(
    RegExp(r"id:\s*'hero_media_path_\$\{[^}]+\}',"),
    "id: _firestore.collection(FirestorePaths.siteSettings).doc().id,"
  );
  adminContent = adminContent.replaceAll(
    RegExp(r"id:\s*'hero_media_type_\$\{[^}]+\}',"),
    "id: _firestore.collection(FirestorePaths.siteSettings).doc().id,"
  );
  adminContent = adminContent.replaceAll(
    RegExp(r"id:\s*'notif-\$\{[^}]+\}',"),
    "id: _firestore.collection(FirestorePaths.notifications).doc().id,"
  );
  adminFile.writeAsStringSync(adminContent);

  var orderFile = File('lib/services/order_service.dart');
  var orderContent = orderFile.readAsStringSync();
  
  orderContent = orderContent.replaceAll(
    RegExp(r"final newId = DateTime\.now\(\)\.millisecondsSinceEpoch\.toString\(\) \+ '_' \+ dummyParentOrders\.length\.toString\(\);"),
    "final newId = firestore.collection(_collectionPath).doc().id;"
  );
  orderContent = orderContent.replaceAll(
    RegExp(r"final batchId = DateTime\.now\(\)\.millisecondsSinceEpoch\.toString\(\) \+ '_' \+ dummyParentOrders\.length\.toString\(\);"),
    "final batchId = firestore.collection(_collectionPath).doc().id;"
  );
  
  orderFile.writeAsStringSync(orderContent);
}
