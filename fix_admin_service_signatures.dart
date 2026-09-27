import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  // Replace methods up to the first brace!
  
  content = content.replaceFirst("static String? resetCoachPassword(User admin, User coach, String newPassword) {", 
                                 "static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) async {");
                                 
  content = content.replaceFirst("static String? createLandingCollection(User admin, LandingCollection collection) {",
                                 "static Future<String?> createLandingCollection(FirebaseFirestore firestore, User admin, LandingCollection collection) async {");

  content = content.replaceFirst("static String? updateLandingCollection(User admin, LandingCollection updatedCollection) {",
                                 "static Future<String?> updateLandingCollection(FirebaseFirestore firestore, User admin, LandingCollection updatedCollection) async {");

  content = content.replaceFirst("static String? deleteLandingCollection(User admin, String collectionId) {",
                                 "static Future<String?> deleteLandingCollection(FirebaseFirestore firestore, User admin, String collectionId) async {");

  content = content.replaceFirst("static String? createTestimonial(User admin, Testimonial testimonial) {",
                                 "static Future<String?> createTestimonial(FirebaseFirestore firestore, User admin, Testimonial testimonial) async {");

  content = content.replaceFirst("static String? updateTestimonial(User admin, Testimonial updatedTestimonial) {",
                                 "static Future<String?> updateTestimonial(FirebaseFirestore firestore, User admin, Testimonial updatedTestimonial) async {");

  content = content.replaceFirst("static String? deleteTestimonial(User admin, String testimonialId) {",
                                 "static Future<String?> deleteTestimonial(FirebaseFirestore firestore, User admin, String testimonialId) async {");

  content = content.replaceFirst("static String? markQuoteAddressed(User admin, String quoteId) {",
                                 "static Future<String?> markQuoteAddressed(FirebaseFirestore firestore, User admin, String quoteId) async {");

  content = content.replaceFirst("static String? updateHeroSettings(User admin, {required String subtitle, String? mediaPath, String? mediaType}) {",
                                 "static Future<String?> updateHeroSettings(FirebaseFirestore firestore, User admin, {required String subtitle, String? mediaPath, String? mediaType}) async {");

  content = content.replaceFirst("static String? removeHeroMedia(User admin) {",
                                 "static Future<String?> removeHeroMedia(FirebaseFirestore firestore, User admin) async {");

  file.writeAsStringSync(content);
}
