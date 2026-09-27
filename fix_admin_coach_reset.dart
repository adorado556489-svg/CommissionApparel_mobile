import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  var pattern = RegExp(r"  static Future<String\?> resetCoachPassword\([\s\S]*?return null;\n  \}");
  
  var replacement = '''  static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    if (newPassword.length < 8) return 'Password must be at least 8 characters.';
    
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index != -1) {
      dummyUsers[index] = dummyUsers[index].copyWith(
        password: newPassword,
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }''';
  
  content = content.replaceFirst(pattern, replacement);
  file.writeAsStringSync(content);
}
