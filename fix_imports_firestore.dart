import 'dart:io';

void main() {
  var files = [
    'lib/screens/admin/admin_coach_edit_screen.dart',
    'lib/screens/admin/admin_content_screens.dart'
  ];
  
  for (var p in files) {
    var file = File(p);
    var content = file.readAsStringSync();
    if (!content.contains("import 'package:cloud_firestore/cloud_firestore.dart';")) {
      content = "import 'package:cloud_firestore/cloud_firestore.dart';\n" + content;
      file.writeAsStringSync(content);
    }
  }
}
