import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst('''
  static String? resetCoachPassword(User admin, User coach, String newPassword) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    if (newPassword.length < 8) return 'Password must be at least 8 characters.';
    
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index == -1) return 'Coach not found';

    dummyUsers[index] = dummyUsers[index].copyWith(
      password: newPassword,
      updatedAt: DateTime.now(),
    );
    return null;
  }
''', '''
  static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    if (newPassword.length < 8) return 'Password must be at least 8 characters.';
    
    try {
      final doc = await firestore.collection('users').doc(coach.id).get();
      if (!doc.exists) return 'Coach not found';
      await doc.reference.update({
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch(e) {
      return e.toString();
    }
  }
''');
  file.writeAsStringSync(content);
}
