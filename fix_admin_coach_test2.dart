import 'dart:io';

void main() {
  var file = File('test/admin_coach_test.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst("test('Admin can reset coach password', () {", "test('Admin can reset coach password', () async {");
  content = content.replaceFirst("final error = AdminService.resetCoachPassword(adminUser, coachUser, 'new_password123');", "final error = await AdminService.resetCoachPassword(firestore, adminUser, coachUser, 'new_password123');");
  
  content = content.replaceFirst("final updatedCoach = dummyUsers.firstWhere((u) => u.id == coachUser.id);", "final doc = await firestore.collection('users').doc(coachUser.id).get(); final updatedCoach = User.fromFirestore(doc);");
  content = content.replaceFirst("AdminService.resetCoachPassword(adminUser, updatedCoach, originalPassword);", "await AdminService.resetCoachPassword(firestore, adminUser, updatedCoach, originalPassword);");
  
  // also deleteCoach!
  content = content.replaceFirst("final error = await AdminService.deleteCoach(FakeFirebaseFirestore(), adminUser, coachUser.id);", "final error = await AdminService.deleteCoach(firestore, adminUser, coachUser.id);");
  
  file.writeAsStringSync(content);
}
