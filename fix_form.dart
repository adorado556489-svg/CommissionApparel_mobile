import 'dart:io';

void main() {
  var file = File('lib/screens/coach/direct_order_form_screen.dart');
  var code = file.readAsStringSync();
  
  var oldInit = """  void _initSelections() {
    final user = context.read<AuthService>().currentUser;
    if (user == null || user.assignedDesignIds.isEmpty) return;

    for (var id in user.assignedDesignIds) {
      final design = dummyDesignCatalog.firstWhere((d) => d.id == id);
      _selections[id] = _DesignSelection(design: design);
    }
    setState(() {});
  }""";
  
  var newInit = """  Future<void> _initSelections() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null || user.assignedDesignIds.isEmpty) return;
    
    final firestore = context.read<FirebaseFirestore>();
    final catalog = await CatalogService.getAllDesignCatalog(firestore);

    for (var id in user.assignedDesignIds) {
      try {
        final design = catalog.firstWhere((d) => d.id == id);
        _selections[id] = _DesignSelection(design: design);
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }""";

  if (!code.contains("import '../../services/catalog_service.dart';")) {
     code = code.replaceFirst("import '../../data/dummy_catalog.dart';", "import '../../data/dummy_catalog.dart';\nimport '../../services/catalog_service.dart';");
  }
  
  if (code.contains(oldInit)) {
    code = code.replaceAll(oldInit, newInit);
    file.writeAsStringSync(code);
    print("direct_order_form_screen updated.");
  } else {
    print("direct_order_form_screen pattern not found.");
  }
}
