import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  
  // The first test is 'Coach with existing store sees dashboard' -> uses coach@example.com
  // The second test is 'Coach without store can create a store' -> uses david.chen@trackclub.org
  // All other tests should use coach@example.com because the database resets and David Chen has no store!
  
  var tests = content.split("testWidgets('");
  for (int i = 2; i < tests.length; i++) { // Skip first two testWidgets
    tests[i] = tests[i].replaceAll('david.chen@trackclub.org', 'coach@example.com');
  }
  
  content = tests.join("testWidgets('");
  file.writeAsStringSync(content);
}
