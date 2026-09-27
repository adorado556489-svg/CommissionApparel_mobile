import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  var pattern = RegExp(r"      if \(index != -1\) \{\s*dummyUsers\[index\] = dummyUsers\[index\]\.copyWith\([\s\S]*?\);\s*\}\s*firstName: firstName,\s*lastName: lastName,\s*email: email,\s*organization: organization,\s*phone: phone,\s*sport: sport,\s*status: status,\s*updatedAt: DateTime\.now\(\),\s*\);\s*return null;");
  
  var replacement = '''
      if (index != -1) {
        dummyUsers[index] = dummyUsers[index].copyWith(
          firstName: firstName,
          lastName: lastName,
          email: email,
          organization: organization,
          phone: phone,
          sport: sport,
          status: status,
          updatedAt: DateTime.now(),
        );
      }
      return null;
''';
  
  content = content.replaceFirst(pattern, replacement);
  file.writeAsStringSync(content);
}
