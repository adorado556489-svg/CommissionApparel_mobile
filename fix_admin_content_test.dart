import 'dart:io';

void main() {
  var file = File('test/admin_content_test.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst('setUp(() {', '''
    late FakeFirebaseFirestore firestore;
    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAdminEnvironment(firestore);
''');

  // Replace FakeFirebaseFirestore() with firestore
  content = content.replaceAll('FakeFirebaseFirestore()', 'firestore');
  
  file.writeAsStringSync(content);
}
