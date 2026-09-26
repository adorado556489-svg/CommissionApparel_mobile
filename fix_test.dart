import 'dart:io';

void main() {
  final file = File('test/admin_coach_test.dart');
  var code = file.readAsStringSync();
  
  // Replace AdminService.updateCoach calls
  code = code.replaceAll("AdminService.updateCoach(\n        adminUser,\n        coachUser,", "await AdminService.updateCoach(\n        FakeFirebaseFirestore(),\n        adminUser,\n        coachUser,");
  
  code = code.replaceAll("AdminService.updateCoach(\n        adminUser,\n        updatedCoach,", "await AdminService.updateCoach(\n        FakeFirebaseFirestore(),\n        adminUser,\n        updatedCoach,");
  
  // The test callback needs to be async
  code = code.replaceAll("test('Admin can update coach information', () {", "test('Admin can update coach information', () async {");
  
  file.writeAsStringSync(code);
  print("Updated admin_coach_test.dart");
}
