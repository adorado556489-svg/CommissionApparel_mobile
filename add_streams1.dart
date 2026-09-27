import 'dart:io';

void main() {
  var file = File('lib/services/store_service.dart');
  var content = file.readAsStringSync();
  if (!content.contains('getPendingStoresStream')) {
    content = content.replaceFirst('class StoreService {', '''class StoreService {
  static Stream<List<TeamStore>> getPendingStoresStream(FirebaseFirestore firestore) {
    return firestore.collection('stores').where('status', isEqualTo: 'pending').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TeamStore.fromFirestore(doc)).toList();
    });
  }
''');
    file.writeAsStringSync(content);
  }
}
