import 'dart:io';

void replaceAllMatching(String path, RegExp regex, String replacement) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(regex, replacement);
  file.writeAsStringSync(content);
}

void main() {
  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? updateLandingCollection[^}]+\}\s*"), 
    "static String? updateLandingCollection(User admin, LandingCollection updatedCollection) {\n    return null;\n  }\n");

  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? createLandingCollection[^}]+\}\s*"), 
    "static String? createLandingCollection(User admin, LandingCollection collection) {\n    return null;\n  }\n");

  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? deleteLandingCollection[^}]+\}\s*"), 
    "static String? deleteLandingCollection(User admin, String collectionId) {\n    return null;\n  }\n");

  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? createTestimonial[^}]+\}\s*"), 
    "static String? createTestimonial(User admin, Testimonial testimonial) {\n    return null;\n  }\n");

  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? updateTestimonial[^}]+\}\s*"), 
    "static String? updateTestimonial(User admin, Testimonial updatedTestimonial) {\n    return null;\n  }\n");

  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? deleteTestimonial[^}]+\}\s*"), 
    "static String? deleteTestimonial(User admin, String testimonialId) {\n    return null;\n  }\n");

  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? markQuoteAddressed[^}]+\}\s*"), 
    "static String? markQuoteAddressed(User admin, String quoteId) {\n    return null;\n  }\n");

  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? resetCoachPassword[^}]+\}\s*"), 
    "static String? resetCoachPassword(User admin, User coach, String newPassword) {\n    return null;\n  }\n");

  replaceAllMatching('lib/services/admin_service.dart', RegExp(r"static String\? updateHeroSettings[^\{]+\{[^\}]+\}\s*(else \{[^}]+\})?\s*(if \([^}]+\}\s*else \{[^}]+\})?\s*(if \([^}]+\}\s*else \{[^}]+\})?[^}]+\}\s*"), 
    "static String? updateHeroSettings(User admin, {required String subtitle, String? mediaPath, String? mediaType}) {\n    return null;\n  }\n");
}
