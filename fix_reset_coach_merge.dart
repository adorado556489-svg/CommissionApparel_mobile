import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  var pattern = '''  static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    if (newPassword.length < 8) return 'Password must be at least 8 characters.';
    
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);''';
    
  var replacement = '''  static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    if (newPassword.length < 8) return 'Password must be at least 8 characters.';
    
    try {
      await firestore.collection('users').doc(coach.id).set({
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('CRITICAL FIRESTORE ERROR [AdminService.resetCoachPassword]: \$e');
      // throw e;
    }
    
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);''';
    
  content = content.replaceFirst(pattern, replacement);
  file.writeAsStringSync(content);
}
