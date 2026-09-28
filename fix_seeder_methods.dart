import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    if (!content.contains('seedCoachStoreEnvironment')) {
      content = content.replaceFirst('}\n', "  static Future<void> seedCoachStoreEnvironment(dynamic firestore) async {}\n  static Future<void> seedParentEnvironment(dynamic firestore) async {}\n}\n");
      file.writeAsStringSync(content);
    }
  }
}
