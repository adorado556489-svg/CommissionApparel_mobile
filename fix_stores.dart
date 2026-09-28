import 'dart:io';

void main() {
  var file = File('lib/services/store_service.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('getPendingStoresStream')) {
    var injection = """
  static Stream<List<TeamStore>> getPendingStoresStream(FirebaseFirestore firestore) {
    return firestore
        .collection(FirestorePaths.teamStores)
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((qs) => qs.docs.map((d) => TeamStore.fromFirestore(d)).toList());
  }
""";
    content = content.replaceFirst(
      "static Future<List<TeamStore>> getPendingStores",
      injection + "\n  static Future<List<TeamStore>> getPendingStores"
    );
    file.writeAsStringSync(content);
    print('Added getPendingStoresStream');
  }
}
