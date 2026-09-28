import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    if (!content.contains('class TestSeeder')) {
      content += '\nclass TestSeeder {\n  static Future<void> populate(dynamic db) async {}\n  static void populateDummyFallbacks() {}\n  static Future<void> seedAdminEnvironment(dynamic firestore) async {}\n  static Future<void> seedAll(dynamic firestore) async {}\n}\n';
      file.writeAsStringSync(content);
    }
  } else {
    file.writeAsStringSync('class TestSeeder {\n  static Future<void> populate(dynamic db) async {}\n  static void populateDummyFallbacks() {}\n  static Future<void> seedAdminEnvironment(dynamic firestore) async {}\n  static Future<void> seedAll(dynamic firestore) async {}\n}\n');
  }
}
