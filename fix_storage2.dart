import 'dart:io';

void main() {
  final path = 'test/storage_service_test.dart';
  var content = File(path).readAsStringSync();

  if (!content.contains('firebase_storage_mocks')) {
    content = content.replaceFirst(
      "import 'package:flutter_test/flutter_test.dart';",
      "import 'package:flutter_test/flutter_test.dart';\nimport 'package:firebase_storage_mocks/firebase_storage_mocks.dart';"
    );
  }

  content = content.replaceAll(
    'mockStorage = null;',
    'mockStorage = MockFirebaseStorage();'
  );

  File(path).writeAsStringSync(content);
  print('Done storage_service_test.dart');
}
