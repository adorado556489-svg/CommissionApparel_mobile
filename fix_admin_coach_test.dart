import 'dart:io';

void main() {
  var file = File('test/admin_coach_test.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst('setUp(() {', '''
    late FakeFirebaseFirestore firestore;
    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAdminEnvironment(firestore);
''');

  // Replace FakeFirebaseFirestore() with firestore
  content = content.replaceAll('FakeFirebaseFirestore()', 'firestore');

  // Replace dummyUsers reads with firestore reads
  content = content.replaceFirst("final updatedCoach = dummyUsers.firstWhere((u) => u.id == coachUser.id);", 
    "final doc = await firestore.collection('users').doc(coachUser.id).get(); final updatedCoach = User.fromFirestore(doc);");
    
  file.writeAsStringSync(content);
}
