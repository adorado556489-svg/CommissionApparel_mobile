import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  var startIndex = content.indexOf('      if (index != -1) {\n        dummyUsers[index] = dummyUsers[index].copyWith(');
  var endIndex = content.indexOf('return null;\n\n  }\n\n  static Future<String?> resetCoachPassword');
  
  if (startIndex != -1 && endIndex != -1) {
    var newBlock = '''
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
  }

  static Future<String?> resetCoachPassword''';
    content = content.substring(0, startIndex) + newBlock + content.substring(endIndex + 64);
    file.writeAsStringSync(content);
    print("Fixed!");
  } else {
    print("Not found! $startIndex, $endIndex");
  }
}
