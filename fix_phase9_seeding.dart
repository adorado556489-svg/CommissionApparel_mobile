import 'dart:io';

void main() {
  var file = File('test/phase9_cleanup_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("""    setUp(() {
      adminUser = dummyUsers.firstWhere((u) => u.role == UserRole.admin);
    });""", """    late FakeFirebaseFirestore firestore;
    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAll(firestore);
      adminUser = dummyUsers.firstWhere((u) => u.role == UserRole.admin);
    });""");
    
    // Also, we need to pass firestore to AdminService.deleteCoach and OrderService.deleteOrder
    content = content.replaceAll("FakeFirebaseFirestore()", "firestore");
  
  file.writeAsStringSync(content);
}
