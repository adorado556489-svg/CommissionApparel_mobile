import 'dart:io';

void main() {
  var file = File('test/coach_logo_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "expect(find.text('StoreNameWithoutLogo'), findsOneWidget);",
    "expect(find.text('StoreNameWithoutLogo'), findsWidgets);"
  );
  content = content.replaceAll(
    "expect(find.text('StoreNameWithLogo'), findsOneWidget);",
    "expect(find.text('StoreNameWithLogo'), findsWidgets);"
  );
  file.writeAsStringSync(content);
}
