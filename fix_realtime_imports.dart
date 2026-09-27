import 'dart:io';

void main() {
  final file = File('test/realtime_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceFirst(
    "import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';",
    "import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';"
  );

  file.writeAsStringSync(content);
}
