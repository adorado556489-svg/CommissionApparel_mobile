import 'dart:io';

void main() {
  var file = File('lib/services/auth_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "final doc = await _firestore.collection(FirestorePaths.users).doc(fbUser.uid).get();",
    "print('AUTH: Fetching user \${fbUser.uid}');\n          final doc = await _firestore.collection(FirestorePaths.users).doc(fbUser.uid).get();\n          print('AUTH: Doc exists? \${doc.exists}');"
  );
  content = content.replaceFirst(
    "_currentUser = User.fromFirestore(doc);",
    "_currentUser = User.fromFirestore(doc);\n            print('AUTH: User set to \${_currentUser?.id}');"
  );
  file.writeAsStringSync(content);
}
