import 'dart:io';

void main() {
  final file = File('lib/screens/public/home_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../widgets/managed_image.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../widgets/managed_image.dart';");
  }
  
  final oldBg = '''    Widget bgImage;
    if (mediaPath != null && mediaPath.isNotEmpty && !mediaPath.startsWith('assets/')) {
      bgImage = Image.file(
        File(mediaPath), // Use dart:io indirectly or import dart:io
        height: 400,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/images/placeholder_hero.png', height: 400, width: double.infinity, fit: BoxFit.cover),
      );
    } else {
      bgImage = Image.asset(
        mediaPath?.isNotEmpty == true ? mediaPath! : 'assets/images/placeholder_hero.png',
        height: 400,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }''';
    
  final newBg = '''    Widget bgImage = ManagedImage.getWidget(
      mediaPath,
      defaultAsset: 'assets/images/placeholder_hero.png',
      height: 400,
      width: double.infinity,
      fit: BoxFit.cover,
    );''';
    
  content = content.replaceFirst(oldBg, newBg);
  file.writeAsStringSync(content);
}
