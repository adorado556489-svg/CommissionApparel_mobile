import 'dart:io';

void main() {
  final file = File('lib/screens/public/store_detail_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../widgets/managed_image.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../widgets/managed_image.dart';");
  }
  
  // 1. Cover Image
  final heroOld = '''          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/placeholder_store.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),''';
  final heroNew = '''          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: ManagedImage.getProvider(store.coverImagePath, defaultAsset: 'assets/images/placeholder_store.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),''';
  content = content.replaceFirst(heroOld, heroNew);
  
  // 2. Logo
  final logoOld = '''              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderSubtle),
                image: coach?.logoPath != null ? DecorationImage(image: FileImage(File(coach!.logoPath!)), fit: BoxFit.cover) : null,
              ),''';
  final logoNewBlock = '''              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderSubtle),
                image: coach?.logoPath != null ? DecorationImage(image: ManagedImage.getProvider(coach!.logoPath!), fit: BoxFit.cover) : null,
              ),''';
  content = content.replaceFirst(logoOld, logoNewBlock);
  
  file.writeAsStringSync(content);
}
