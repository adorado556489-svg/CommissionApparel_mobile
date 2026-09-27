import 'dart:io';
void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  var pattern = RegExp(r"      if \(index != -1\) \{\s*dummyUsers\[index\] = dummyUsers\[index\]\.copyWith\([\s\S]*?\);\s*\}\s*firstName: firstName,\s*lastName: lastName,");
  print(pattern.hasMatch(content));
}
