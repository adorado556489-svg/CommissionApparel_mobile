import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../widgets/managed_image.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../widgets/managed_image.dart';");
  }
  file.writeAsStringSync(content);
}
