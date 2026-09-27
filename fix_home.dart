import 'dart:io';

void main() {
  final file = File('lib/screens/public/home_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../widgets/managed_image.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../widgets/managed_image.dart';");
  }
  
  final startStr = "Widget bgImage;\n    if (mediaPath != null";
  final endStr = "    } else {\n      bgImage = Image.asset";
  
  final startIdx = content.indexOf(startStr);
  final endIdx = content.indexOf(endStr);
  
  if (startIdx != -1 && endIdx != -1) {
    final before = content.substring(0, startIdx);
    final after = content.substring(endIdx);
    final newBlock = '''Widget bgImage = ManagedImage.getWidget(
      mediaPath,
      defaultAsset: 'assets/images/placeholder_hero.png',
      height: 400,
      width: double.infinity,
      fit: BoxFit.cover,
    );
    if (false) {'''; // Just to match the } else { syntax
    
    content = before + newBlock + after;
  }
  
  file.writeAsStringSync(content);
}
