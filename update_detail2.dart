import 'dart:io';

void main() {
  final file = File('lib/screens/public/store_detail_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../widgets/managed_image.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../widgets/managed_image.dart';");
  }
  
  // 1. Cover Image
  final heroOld = '''  Widget _buildHero(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppTheme.primary.withValues(alpha: 0.1),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/team-store-background-v2.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          Container(color: Colors.black.withValues(alpha: 0.4)),
        ],
      ),
    );
  }''';
  
  // Notice _buildHero in the actual file doesn't take store! It takes BuildContext. 
  // Let me change the signature. I will replace it directly by index.
  
  final buildHeroIdx = content.indexOf('Widget _buildHero(BuildContext context) {');
  final endBuildHeroIdx = content.indexOf('Widget _buildHeaderInfo', buildHeroIdx);
  if (buildHeroIdx != -1 && endBuildHeroIdx != -1) {
    final beforeHero = content.substring(0, buildHeroIdx);
    final afterHero = content.substring(endBuildHeroIdx);
    final newHero = '''Widget _buildHero(BuildContext context, dynamic store) {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppTheme.primary.withValues(alpha: 0.1),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ManagedImage.getWidget(
            store.coverImagePath,
            defaultAsset: 'assets/images/team-store-background-v2.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.4)),
        ],
      ),
    );
  }\n\n  ''';
    content = beforeHero + newHero + afterHero;
  }
  
  content = content.replaceFirst('_buildHero(context)', '_buildHero(context, store)');
  
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
