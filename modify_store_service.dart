import 'dart:io';

void main() {
  var file = File('lib/services/store_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "static Future<TeamStore?> getActiveStoreForCoach(FirebaseFirestore firestore, String coachId) async {",
    "static Future<TeamStore?> getActiveStoreForCoach(FirebaseFirestore firestore, String coachId) async {\n    print('GETTING STORE FOR COACH: \$coachId');"
  );
  content = content.replaceFirst(
    ".limit(1)\n            .get();",
    ".limit(1)\n            .get();\n        print('FOUND DOCS: \${qs.docs.length}');"
  );
  file.writeAsStringSync(content);
}
