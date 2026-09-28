import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth, fakeFirestore));", "print('TEST: CURRENT USER IS \${auth.currentUser?.id}');\n      await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth, fakeFirestore));");
  file.writeAsStringSync(content);
}
