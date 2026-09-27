import 'dart:io';

void main() {
  var file = File('lib/screens/admin/admin_content_screens.dart');
  var content = file.readAsStringSync();
  
  // _save(String? mediaPath)
  content = content.replaceFirst("AdminService.updateHeroSettings(admin, subtitle: _subtitleCtrl.text, mediaPath: mediaPath);", "await AdminService.updateHeroSettings(FirebaseFirestore.instance, admin, subtitle: _subtitleCtrl.text, mediaPath: mediaPath);");
  content = content.replaceFirst("void _save(String? mediaPath) {", "Future<void> _save(String? mediaPath) async {");
  content = content.replaceFirst("onPressed: () => _save(_mediaPath),", "onPressed: () async => await _save(_mediaPath),");

  // removeHeroMedia
  content = content.replaceFirst("onPressed: () {", "onPressed: () async {");
  content = content.replaceFirst("AdminService.removeHeroMedia(admin);", "await AdminService.removeHeroMedia(FirebaseFirestore.instance, admin);");

  // createLandingCollection
  content = content.replaceFirst("AdminService.createLandingCollection(admin, newCollection);", "await AdminService.createLandingCollection(FirebaseFirestore.instance, admin, newCollection);");
  content = content.replaceFirst("AdminService.updateLandingCollection(admin, newCollection);", "await AdminService.updateLandingCollection(FirebaseFirestore.instance, admin, newCollection);");
  content = content.replaceAll("onPressed: () {", "onPressed: () async {");
  content = content.replaceFirst("AdminService.updateLandingCollection(admin, c.copyWith(imagePath: picked.path));", "await AdminService.updateLandingCollection(FirebaseFirestore.instance, admin, c.copyWith(imagePath: picked.path));");
  content = content.replaceFirst("AdminService.deleteLandingCollection(admin, c.id);", "await AdminService.deleteLandingCollection(FirebaseFirestore.instance, admin, c.id);");

  // Testimonials
  content = content.replaceFirst("AdminService.createTestimonial(admin, newT);", "await AdminService.createTestimonial(FirebaseFirestore.instance, admin, newT);");
  content = content.replaceFirst("AdminService.updateTestimonial(admin, newT);", "await AdminService.updateTestimonial(FirebaseFirestore.instance, admin, newT);");
  content = content.replaceFirst("AdminService.updateTestimonial(admin, t.copyWith(imagePath: picked.path));", "await AdminService.updateTestimonial(FirebaseFirestore.instance, admin, t.copyWith(imagePath: picked.path));");
  content = content.replaceFirst("AdminService.deleteTestimonial(admin, t.id);", "await AdminService.deleteTestimonial(FirebaseFirestore.instance, admin, t.id);");

  // markQuoteAddressed
  content = content.replaceFirst("AdminService.markQuoteAddressed(admin, q.id);", "await AdminService.markQuoteAddressed(FirebaseFirestore.instance, admin, q.id);");

  file.writeAsStringSync(content);
}
