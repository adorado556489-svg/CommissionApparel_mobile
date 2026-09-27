import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  // createLandingCollection
  content = content.replaceFirst(
'''  static String? createLandingCollection(User admin, LandingCollection collection) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummyLandingCollections.add(collection);
    _sortLandingCollections();
    return null;
  }''', 
'''  static Future<String?> createLandingCollection(FirebaseFirestore firestore, User admin, LandingCollection collection) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('landingCollections').doc(collection.id).set(collection.toFirestore());
    return null;
  }'''
  );

  // updateLandingCollection
  content = content.replaceFirst(
'''  static String? updateLandingCollection(User admin, LandingCollection updatedCollection) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final index = dummyLandingCollections.indexWhere((c) => c.id == updatedCollection.id);
    if (index == -1) return 'Collection not found';
    dummyLandingCollections[index] = updatedCollection.copyWith(updatedAt: DateTime.now());
    _sortLandingCollections();
    return null;
  }''',
'''  static Future<String?> updateLandingCollection(FirebaseFirestore firestore, User admin, LandingCollection updatedCollection) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('landingCollections').doc(updatedCollection.id).update(updatedCollection.copyWith(updatedAt: DateTime.now()).toFirestore());
    return null;
  }'''
  );

  // deleteLandingCollection
  content = content.replaceFirst(
'''  static String? deleteLandingCollection(User admin, String collectionId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummyLandingCollections.removeWhere((c) => c.id == collectionId);
    return null;
  }''',
'''  static Future<String?> deleteLandingCollection(FirebaseFirestore firestore, User admin, String collectionId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('landingCollections').doc(collectionId).delete();
    return null;
  }'''
  );
  
  // _sortLandingCollections
  content = content.replaceFirst(
'''  static void _sortLandingCollections() {
    dummyLandingCollections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }''', '');

  // createTestimonial
  content = content.replaceFirst(
'''  static String? createTestimonial(User admin, Testimonial testimonial) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummyTestimonials.add(testimonial);
    _sortTestimonials();
    return null;
  }''',
'''  static Future<String?> createTestimonial(FirebaseFirestore firestore, User admin, Testimonial testimonial) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('testimonials').doc(testimonial.id).set(testimonial.toFirestore());
    return null;
  }'''
  );

  // updateTestimonial
  content = content.replaceFirst(
'''  static String? updateTestimonial(User admin, Testimonial updatedTestimonial) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final index = dummyTestimonials.indexWhere((t) => t.id == updatedTestimonial.id);
    if (index == -1) return 'Testimonial not found';
    dummyTestimonials[index] = updatedTestimonial.copyWith(updatedAt: DateTime.now());
    _sortTestimonials();
    return null;
  }''',
'''  static Future<String?> updateTestimonial(FirebaseFirestore firestore, User admin, Testimonial updatedTestimonial) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('testimonials').doc(updatedTestimonial.id).update(updatedTestimonial.copyWith(updatedAt: DateTime.now()).toFirestore());
    return null;
  }'''
  );

  // deleteTestimonial
  content = content.replaceFirst(
'''  static String? deleteTestimonial(User admin, String testimonialId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummyTestimonials.removeWhere((t) => t.id == testimonialId);
    return null;
  }''',
'''  static Future<String?> deleteTestimonial(FirebaseFirestore firestore, User admin, String testimonialId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('testimonials').doc(testimonialId).delete();
    return null;
  }'''
  );

  // _sortTestimonials
  content = content.replaceFirst(
'''  static void _sortTestimonials() {
    dummyTestimonials.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }''', '');
  
  // markQuoteAddressed
  content = content.replaceFirst(
'''  static String? markQuoteAddressed(User admin, String quoteId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final index = dummyQuoteRequests.indexWhere((q) => q.id == quoteId);
    if (index == -1) return 'Quote not found';

    dummyQuoteRequests[index] = dummyQuoteRequests[index].copyWith(
      isAddressed: true,
      updatedAt: DateTime.now(),
    );
    return null;
  }''',
'''  static Future<String?> markQuoteAddressed(FirebaseFirestore firestore, User admin, String quoteId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('quoteRequests').doc(quoteId).update({'isAddressed': true, 'updatedAt': FieldValue.serverTimestamp()});
    return null;
  }'''
  );
  
  // updateHeroSettings
  content = content.replaceFirst(
'''  static String? updateHeroSettings(User admin, {required String subtitle, String? mediaPath, String? mediaType}) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    final subIndex = dummySiteSettings.indexWhere((s) => s.key == 'hero_subtitle');
    if (subIndex != -1) {
      dummySiteSettings[subIndex] = dummySiteSettings[subIndex].copyWith(value: subtitle, updatedAt: DateTime.now());
    } else {
      dummySiteSettings.add(SiteSetting(id: 'hero_subtitle', key: 'hero_subtitle', value: subtitle, createdAt: DateTime.now(), updatedAt: DateTime.now()));
    }

    if (mediaPath != null && mediaType != null) {
      final pathIndex = dummySiteSettings.indexWhere((s) => s.key == 'hero_media_path');
      if (pathIndex != -1) {
        dummySiteSettings[pathIndex] = dummySiteSettings[pathIndex].copyWith(value: mediaPath, updatedAt: DateTime.now());
      } else {
        dummySiteSettings.add(SiteSetting(id: 'hero_media_path', key: 'hero_media_path', value: mediaPath, createdAt: DateTime.now(), updatedAt: DateTime.now()));
      }
      
      final typeIndex = dummySiteSettings.indexWhere((s) => s.key == 'hero_media_type');
      if (typeIndex != -1) {
        dummySiteSettings[typeIndex] = dummySiteSettings[typeIndex].copyWith(value: mediaType, updatedAt: DateTime.now());
      } else {
        dummySiteSettings.add(SiteSetting(id: 'hero_media_type', key: 'hero_media_type', value: mediaType, createdAt: DateTime.now(), updatedAt: DateTime.now()));
      }
    }
    return null;
  }''',
'''  static Future<String?> updateHeroSettings(FirebaseFirestore firestore, User admin, {required String subtitle, String? mediaPath, String? mediaType}) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final batch = firestore.batch();
    batch.set(firestore.collection('siteSettings').doc('hero_subtitle'), {'key': 'hero_subtitle', 'value': subtitle, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    if (mediaPath != null) {
      batch.set(firestore.collection('siteSettings').doc('hero_media_path'), {'key': 'hero_media_path', 'value': mediaPath, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      batch.set(firestore.collection('siteSettings').doc('hero_media_type'), {'key': 'hero_media_type', 'value': mediaType, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    }
    await batch.commit();
    return null;
  }'''
  );

  // removeHeroMedia
  content = content.replaceFirst(
'''  static String? removeHeroMedia(User admin) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummySiteSettings.removeWhere((s) => s.key == 'hero_media_path' || s.key == 'hero_media_type');
    return null;
  }''',
'''  static Future<String?> removeHeroMedia(FirebaseFirestore firestore, User admin) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    await firestore.collection('siteSettings').doc('hero_media_path').delete();
    await firestore.collection('siteSettings').doc('hero_media_type').delete();
    return null;
  }'''
  );

  file.writeAsStringSync(content);
}
