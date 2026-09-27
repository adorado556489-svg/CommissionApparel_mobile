import 'dart:io';

void main() {
  // Fix admin_batch_test.dart
  var file = File('test/admin_batch_test.dart');
  var content = file.readAsStringSync();
  content = "import 'package:commission_apparel_flutter/constants/firestore_paths.dart';\n" + content;
  content = content.replaceAll(RegExp(r"status: 'Submitted to Admin',\n\s*batchId: batchId,\n"), "status: 'Submitted to Admin',\n");
  file.writeAsStringSync(content);
}
