import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "final design = _assignedDesigns.firstWhere((d) => d.id == item.designCatalogId);\n    if (retailPrice < design.wholesalePrice)",
    "if (retailPrice < item.wholesalePrice)"
  );
  file.writeAsStringSync(content);
}
