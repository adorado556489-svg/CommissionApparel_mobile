import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();

  var start = content.indexOf('  static Future<String?> updateCoach(FirebaseFirestore firestore, User admin, User coach, {');
  var end = content.indexOf('  static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) \r\nasync {');
  if (end == -1) end = content.indexOf('  static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) \nasync {');
  if (end == -1) end = content.indexOf('  static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) async {');
  if (end == -1) end = content.indexOf('  static Future<String?> resetCoachPassword');

  if (start != -1 && end != -1) {
    var replacement = '''  static Future<String?> updateCoach(FirebaseFirestore firestore, User admin, User coach, {
    required String firstName,
    required String lastName,
    required String email,
    required String organization,
    required String phone,
    required String sport,
    required String status,
  }) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    // Check email uniqueness in Firestore if possible
    try {
      final qs = await firestore.collection('users').where('email', isEqualTo: email).get();
      if (qs.docs.isNotEmpty && qs.docs.first.id != coach.id) {
        return 'Email already in use.';
      }
      
      final doc = await firestore.collection('users').doc(coach.id).get();
      if (doc.exists) {
        await firestore.collection('users').doc(coach.id).update({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'organization': organization,
          'phone': phone,
          'sport': sport,
          'status': status,
        });
      }
    } on FirebaseException catch (e) {
      if (e.code != 'not-found' && e.code != 'unimplemented') {
        print('CRITICAL FIRESTORE ERROR [AdminService.updateCoach]: \${e.message}');
        throw e;
      }
    }
    
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
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

''';
    content = content.substring(0, start) + replacement + content.substring(end);
    file.writeAsStringSync(content);
    print("Replaced!");
  } else {
    print("Failed to find boundaries! $start, $end");
  }
}
