import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  if (!content.contains("import '../constants/firestore_paths.dart';")) {
    content = content.replaceFirst("import 'package:cloud_firestore/cloud_firestore.dart';", "import 'package:cloud_firestore/cloud_firestore.dart';\nimport '../constants/firestore_paths.dart';");
    file.writeAsStringSync(content);
  }
}
