import 'dart:io';

void main() {
  var file = File('test/auth_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("test('Valid Admin login', () async {", """test('Valid Admin login', () async {
      print('--- TEST START ---');
      final docs = await firestore.collection('users').get();
      print('Users in firestore: \${docs.docs.map((d) => "\${d.id} (\${d.data()['email']})").toList()}');
""");
  file.writeAsStringSync(content);
}
