import 'dart:io';

void main() {
  var file = File('lib/services/catalog_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceAll(
    "    try { return dummyDesignCollections; } catch (_) { return []; }",
    "    return [];"
  );
  content = content.replaceAll(
    "    try { return dummyDesignCatalog; } catch (_) { return []; }",
    "    return [];"
  );
  content = content.replaceAll(
    "    try { return dummyDesignCatalog.firstWhere((d) => d.id == designId); } catch (_) { return null; }",
    "    return null;"
  );
  content = content.replaceAll(
    "    } catch (_) {\n      return dummyDesignCatalog.where((d) => collection.designIds.contains(d.id)).toList();\n    }",
    "    } catch (e) {\n      _handleError(e, 'CatalogService');\n      return [];\n    }"
  );

  file.writeAsStringSync(content);
}
