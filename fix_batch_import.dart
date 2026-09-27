import 'dart:io';

void main() {
  var file = File('test/admin_batch_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("import 'package:commission_apparel_flutter/models/parent_order.dart';", "import 'package:commission_apparel_flutter/models/parent_order.dart';\nimport 'package:commission_apparel_flutter/constants/firestore_paths.dart';");
  file.writeAsStringSync(content);
}
