import 'dart:io';

void main() {
  var file = File('test/phase9_cleanup_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("  group('Phase 9 Cleanup Tests', () {", "  group('Phase 9 Cleanup Tests', () {\n    late FakeFirebaseFirestore firestore;\n    setUp(() async { firestore = FakeFirebaseFirestore(); await TestSeeder.seedAll(firestore); });");
  
  // also fix the fact that AdminService.deleteCoach expects firestore!
  content = content.replaceAll("AdminService.deleteCoach(FakeFirebaseFirestore(),", "AdminService.deleteCoach(firestore,");
  content = content.replaceAll("OrderService.deleteOrder(FakeFirebaseFirestore(),", "OrderService.deleteOrder(firestore,");
  file.writeAsStringSync(content);
}
