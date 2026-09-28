import 'dart:io';
void main() {
  var testFiles = ['test/realtime_test.dart', 'test/storage_service_test.dart'];
  for (var path in testFiles) {
    var file = File(path);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      content = content.replaceFirst('\nclass TestSeeder { static Future<void> populate(dynamic db) async {} static void populateDummyFallbacks() {} static Future<void> seedAdminEnvironment(dynamic firestore) async {} static Future<void> seedAll(dynamic firestore) async {} }\n', '');
      file.writeAsStringSync(content);
    }
  }
}
