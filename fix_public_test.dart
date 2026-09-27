import 'dart:io';

void main() {
  var file = File('test/public_ui_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("globalFirestore = FakeFirebaseFirestore();", "late FakeFirebaseFirestore globalFirestore;\nglobalFirestore = FakeFirebaseFirestore();");
  if (!content.contains("late FakeFirebaseFirestore globalFirestore;")) {
      // it was probably replaced poorly or missed, but I can just delete these 3 lines
      content = content.replaceAll("globalFirestore = FakeFirebaseFirestore();", "");
      content = content.replaceAll("await TestSeeder.seedAdminEnvironment(globalFirestore);", "");
      content = content.replaceAll("await TestSeeder.seedCoachStoreEnvironment(globalFirestore);", "");
  }
  file.writeAsStringSync(content);
}
