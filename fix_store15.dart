import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("))); has unbatched order-1", "))); // has unbatched order-1");
  file.writeAsStringSync(content);
}
