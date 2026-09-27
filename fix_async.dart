import 'dart:io';

void main() {
  final file = File('lib/screens/admin/widgets/admin_catalog_tab.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "onPressed: () {", 
    "onPressed: () async {"
  );
  file.writeAsStringSync(content);
}
