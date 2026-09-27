import 'dart:io';

void main() {
  final file = File('lib/screens/public/store_search_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../widgets/managed_image.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../widgets/managed_image.dart';");
  }
  
  final logoOld = '''                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderSubtle),
                        image: coach.logoPath != null 
                          ? DecorationImage(image: FileImage(File(coach.logoPath!)), fit: BoxFit.cover)
                          : null,
                      ),''';
  final logoNewBlock = '''                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderSubtle),
                        image: coach.logoPath != null 
                          ? DecorationImage(image: ManagedImage.getProvider(coach.logoPath!), fit: BoxFit.cover)
                          : null,
                      ),''';
  content = content.replaceFirst(logoOld, logoNewBlock);
  file.writeAsStringSync(content);
}
