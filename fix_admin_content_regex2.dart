import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r"static String\? createLandingCollection[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> createLandingCollection(FirebaseFirestore firestore, User admin, LandingCollection collection) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('landingCollections').doc(collection.id).set(collection.toFirestore());
    return null;
  }''');

  content = content.replaceAll(RegExp(r"static String\? updateLandingCollection[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> updateLandingCollection(FirebaseFirestore firestore, User admin, LandingCollection updatedCollection) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('landingCollections').doc(updatedCollection.id).update(updatedCollection.copyWith(updatedAt: DateTime.now()).toFirestore());
    return null;
  }''');

  content = content.replaceAll(RegExp(r"static String\? deleteLandingCollection[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> deleteLandingCollection(FirebaseFirestore firestore, User admin, String collectionId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('landingCollections').doc(collectionId).delete();
    return null;
  }''');

  content = content.replaceAll(RegExp(r"static String\? createTestimonial[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> createTestimonial(FirebaseFirestore firestore, User admin, Testimonial testimonial) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('testimonials').doc(testimonial.id).set(testimonial.toFirestore());
    return null;
  }''');

  content = content.replaceAll(RegExp(r"static String\? updateTestimonial[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> updateTestimonial(FirebaseFirestore firestore, User admin, Testimonial updatedTestimonial) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('testimonials').doc(updatedTestimonial.id).update(updatedTestimonial.copyWith(updatedAt: DateTime.now()).toFirestore());
    return null;
  }''');

  content = content.replaceAll(RegExp(r"static String\? deleteTestimonial[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> deleteTestimonial(FirebaseFirestore firestore, User admin, String testimonialId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('testimonials').doc(testimonialId).delete();
    return null;
  }''');

  content = content.replaceAll(RegExp(r"static String\? markQuoteAddressed[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> markQuoteAddressed(FirebaseFirestore firestore, User admin, String quoteId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('quoteRequests').doc(quoteId).update({'isAddressed': true, 'updatedAt': FieldValue.serverTimestamp()});
    return null;
  }''');

  content = content.replaceAll(RegExp(r"static String\? updateHeroSettings[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> updateHeroSettings(FirebaseFirestore firestore, User admin, {required String subtitle, String? mediaPath, String? mediaType}) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final batch = firestore.batch();
    batch.set(firestore.collection('siteSettings').doc('hero_subtitle'), {'key': 'hero_subtitle', 'value': subtitle, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    if (mediaPath != null) {
      batch.set(firestore.collection('siteSettings').doc('hero_media_path'), {'key': 'hero_media_path', 'value': mediaPath, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      if (mediaType != null) batch.set(firestore.collection('siteSettings').doc('hero_media_type'), {'key': 'hero_media_type', 'value': mediaType, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    }
    await batch.commit();
    return null;
  }''');

  content = content.replaceAll(RegExp(r"static String\? removeHeroMedia[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> removeHeroMedia(FirebaseFirestore firestore, User admin) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('siteSettings').doc('hero_media_path').delete();
    await firestore.collection('siteSettings').doc('hero_media_type').delete();
    return null;
  }''');
  
  content = content.replaceAll(RegExp(r"static String\? resetCoachPassword[\s\S]*?return null;\n  }", dotAll: true), 
'''static Future<String?> resetCoachPassword(FirebaseFirestore firestore, User admin, User coach, String newPassword) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    if (newPassword.length < 8) return 'Password must be at least 8 characters.';
    try {
      await firestore.collection('users').doc(coach.id).update({'password': newPassword, 'updatedAt': FieldValue.serverTimestamp()});
      return null;
    } catch(e) {
      return e.toString();
    }
  }''');

  file.writeAsStringSync(content);
}
