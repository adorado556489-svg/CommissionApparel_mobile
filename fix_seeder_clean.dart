import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  file.writeAsStringSync('''
class TestSeeder {
  static Future<void> populate(dynamic db) async {}
  static void populateDummyFallbacks() {}
  static Future<void> seedAdminEnvironment(dynamic firestore) async {}
  static Future<void> seedAll(dynamic firestore) async {}
  static Future<void> seedCoachStoreEnvironment(dynamic firestore) async {}
  static Future<void> seedParentEnvironment(dynamic firestore) async {}
}
''');
}
