import 'dart:io';

void main() {
  final file = File('lib/screens/admin/admin_content_screens.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../widgets/managed_image.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../widgets/managed_image.dart';");
  }
  
  final oldRender = '''                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: FileImage(File(mediaPath)), fit: BoxFit.cover),
                        ),
                      ),''';
  final newRender = '''                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: ManagedImage.getProvider(mediaPath), fit: BoxFit.cover),
                        ),
                      ),''';
  content = content.replaceFirst(oldRender, newRender);
  file.writeAsStringSync(content);
}
