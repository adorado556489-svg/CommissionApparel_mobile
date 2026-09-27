import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('class AdminService {', '''class AdminService {
  static Future<void> approveStore(FirebaseFirestore firestore, String storeId) async {
    await firestore.collection('stores').doc(storeId).update({'status': 'approved'});
  }
''');
  file.writeAsStringSync(content);
}
