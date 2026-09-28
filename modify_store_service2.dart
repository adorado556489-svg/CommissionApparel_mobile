import 'dart:io';

void main() {
  var file = File('lib/services/store_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "print('FOUND DOCS: \${qs.docs.length}');",
    "print('FOUND DOCS: \${qs.docs.length}');\n        final all = await firestore.collection(FirestorePaths.teamStores).get();\n        for(var doc in all.docs) print('ALL STORES: \${doc.data()}');"
  );
  file.writeAsStringSync(content);
}
