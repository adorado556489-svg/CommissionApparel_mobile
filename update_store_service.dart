import 'dart:io';

void main() {
  final file = File('lib/services/store_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  final streamMethod = '''  static Stream<List<TeamStore>> getPendingStoresStream(FirebaseFirestore firestore) {
    return firestore
        .collection(FirestorePaths.teamStores)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((qs) {
          if (qs.docs.isEmpty) {
            return dummyTeamStores.where((s) => s.status == 'pending').toList();
          }
          return qs.docs.map((d) => TeamStore.fromFirestore(d)).toList();
        });
  }

  static Future<List<TeamStore>> getPendingStores''';
  
  content = content.replaceFirst('static Future<List<TeamStore>> getPendingStores', streamMethod);
  file.writeAsStringSync(content);
}
