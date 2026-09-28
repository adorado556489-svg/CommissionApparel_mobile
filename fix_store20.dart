import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "await tester.tap(find.text('SUBMIT MASTER ORDER'));\n      await tester.pumpAndSettle();\n      \n      expect(find.text('Master order submitted successfully!'), findsOneWidget);",
    "await tester.tap(find.text('SUBMIT MASTER ORDER'));\n      await tester.pump(const Duration(milliseconds: 100));\n      \n      expect(find.text('Master order submitted successfully!'), findsOneWidget);"
  );
  file.writeAsStringSync(content);
}
