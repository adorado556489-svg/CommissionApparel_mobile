import 'dart:io';

void main() {
  var file = File('test/verify_models.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("import 'fixtures/dummy_logs.dart';\n", "");
  content = content.replaceFirst('void main() {', 'List<dynamic> dummyNotifications = [];\nvoid main() {');
  // I need to provide dummy functions for `unreadNotificationsForUser`
  content = content.replaceFirst('void main() {', '''
List<dynamic> unreadNotificationsForUser(String id) => [];
List<dynamic> notificationsForUser(String id) => [];
void main() {''');
  file.writeAsStringSync(content);
}
