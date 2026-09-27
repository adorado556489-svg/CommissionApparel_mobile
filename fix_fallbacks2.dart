import 'dart:io';

void main() {
  var file = File('lib/services/dummy_fallbacks.dart');
  var content = file.readAsStringSync();
  if (!content.contains('dummyCoaches')) {
    content += "\nList<User> dummyCoaches = [];\n";
    file.writeAsStringSync(content);
  }
}
