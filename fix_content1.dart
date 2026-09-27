import 'dart:io';

void main() {
  var file = File('lib/screens/admin/admin_content_screens.dart');
  var code = file.readAsStringSync();

  // Add ContentService and CatalogService imports
  if (!code.contains("import '../../services/content_service.dart';")) {
    code = code.replaceFirst(
        "import '../../data/dummy_quotes.dart';",
        "import '../../data/dummy_quotes.dart';\nimport '../../services/content_service.dart';\nimport '../../services/catalog_service.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:uuid/uuid.dart';");
  }

  // --- AdminHeroEditScreen ---
  code = code.replaceFirst(
    "final s = dummySiteSettings.firstWhere((s) => s.key == 'hero_subtitle', orElse: () => throw Exception());\n    _subtitleCtrl.text = s.value ?? '';",
    "ContentService.getSiteSettings(context.read<FirebaseFirestore>()).then((settings) {\n      final s = SiteSetting.getValue(settings, 'hero_subtitle');\n      if (mounted) setState(() => _subtitleCtrl.text = s ?? '');\n    });"
  );
  
  // Replace AdminService.updateHeroSettings
  var oldHeroSave = """  void _save(String? mediaPath) {
    final admin = context.read<AuthService>().currentUser!;
    AdminService.updateHeroSettings(admin, subtitle: _subtitleCtrl.text, mediaPath: mediaPath);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hero settings updated successfully.')));
    setState(() {});
  }""";
  
  var newHeroSave = """  Future<void> _save(String? mediaPath) async {
    final firestore = context.read<FirebaseFirestore>();
    
    final subtitleSetting = SiteSetting(
      id: 'setting-hero-subtitle',
      key: 'hero_subtitle',
      value: _subtitleCtrl.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ContentService.updateSiteSetting(firestore, subtitleSetting);
    
    if (mediaPath != null) {
       final mediaSetting = SiteSetting(
        id: 'setting-hero-media',
        key: 'hero_media_path',
        value: mediaPath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ContentService.updateSiteSetting(firestore, mediaSetting);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hero settings updated successfully.')));
      setState(() {});
    }
  }""";
  code = code.replaceFirst(oldHeroSave, newHeroSave);

  // --- AdminLandingCollectionsScreen ---
  // In _AdminLandingCollectionsScreenState, add:
  // List<LandingCollection> _collections = [];
  // bool _isLoading = true;
  // initState() { _loadData(); }
  
  // Wait, this file is huge. I'll write a Python script or specialized replacement to handle it carefully.
  file.writeAsStringSync(code);
  print("Saved partial admin_content_screens.dart");
}
