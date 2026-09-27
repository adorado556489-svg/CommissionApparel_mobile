import 'dart:io';

void main() {
  var files = [
    'test/admin_coach_test.dart',
    'test/admin_content_test.dart'
  ];
  for (var p in files) {
    var file = File(p);
    var content = file.readAsStringSync();
    content = content.replaceFirst("firestore = firestore;", "firestore = FakeFirebaseFirestore();");
    
    // For admin_content_test.dart, add missing imports
    if (p == 'test/admin_content_test.dart') {
      if (!content.contains("import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';")) {
        content = "import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';\n" + content;
      }
      if (!content.contains("import 'helpers/test_seeder.dart';")) {
        content = "import 'helpers/test_seeder.dart';\n" + content;
      }
      
      // Fix missing firestore parameter
      content = content.replaceFirst("final error = AdminService.updateHeroSettings(adminUser, subtitle: 'New Subtitle', mediaPath: 'path/to/img.png');", 
      "final error = await AdminService.updateHeroSettings(firestore, adminUser, subtitle: 'New Subtitle', mediaPath: 'path/to/img.png');");
      content = content.replaceFirst("AdminService.updateHeroSettings(adminUser, subtitle: originalSub!);", 
      "await AdminService.updateHeroSettings(firestore, adminUser, subtitle: originalSub!);");
      
      content = content.replaceFirst("error = AdminService.updateLandingCollection(adminUser, updatedCollection);", 
      "error = await AdminService.updateLandingCollection(firestore, adminUser, updatedCollection);");
      
      content = content.replaceFirst("error = AdminService.updateTestimonial(adminUser, updatedTestimonial);", 
      "error = await AdminService.updateTestimonial(firestore, adminUser, updatedTestimonial);");
      
      content = content.replaceFirst("error = AdminService.deleteTestimonial(adminUser, 'testi-test');", 
      "error = await AdminService.deleteTestimonial(firestore, adminUser, 'testi-test');");
      
      content = content.replaceFirst("final error = AdminService.markQuoteAddressed(adminUser, quoteId);", 
      "final error = await AdminService.markQuoteAddressed(firestore, adminUser, quoteId);");
      
      content = content.replaceFirst("test('Admin can mark quote request as addressed', () {", "test('Admin can mark quote request as addressed', () async {");
    }
    
    file.writeAsStringSync(content);
  }
}
