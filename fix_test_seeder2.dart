import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("f.dummyNotifications.clear(); f.dummyNotifications.addAll(dummyNotifications);", "");
  content = content.replaceFirst("import '../fixtures/dummy_quotes.dart';", "import '../fixtures/dummy_quotes.dart';\nimport 'package:commission_apparel_flutter/models/user.dart';");
  file.writeAsStringSync(content);
}
