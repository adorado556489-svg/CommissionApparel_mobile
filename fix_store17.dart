import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "await tester.tap(find.text('SUBMIT MASTER ORDER'));",
    "await tester.ensureVisible(find.text('SUBMIT MASTER ORDER'));\n      await tester.tap(find.text('SUBMIT MASTER ORDER'));"
  );
  file.writeAsStringSync(content);
}
