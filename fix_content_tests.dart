import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  var newBlock = '''
  // --- LANDING COLLECTIONS ---

  static Future<String?> createLandingCollection(FirebaseFirestore firestore, User admin, LandingCollection collection) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('landingCollections').doc(collection.id).set(collection.toMap());
    } catch (e) {}
    dummyLandingCollections.add(collection);
    _sortLandingCollections();
    return null;
  }

  static Future<String?> updateLandingCollection(FirebaseFirestore firestore, User admin, LandingCollection updatedCollection) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('landingCollections').doc(updatedCollection.id).update(updatedCollection.toMap());
    } catch (e) {}
    final index = dummyLandingCollections.indexWhere((c) => c.id == updatedCollection.id);
    if (index != -1) {
      dummyLandingCollections[index] = updatedCollection;
      _sortLandingCollections();
    }
    return null;
  }

  static Future<String?> deleteLandingCollection(FirebaseFirestore firestore, User admin, String collectionId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('landingCollections').doc(collectionId).delete();
    } catch (e) {}
    dummyLandingCollections.removeWhere((c) => c.id == collectionId);
    return null;
  }

  static void _sortLandingCollections() {
    dummyLandingCollections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // --- TESTIMONIALS ---

  static Future<String?> createTestimonial(FirebaseFirestore firestore, User admin, Testimonial testimonial) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('testimonials').doc(testimonial.id).set(testimonial.toMap());
    } catch (e) {}
    dummyTestimonials.add(testimonial);
    _sortTestimonials();
    return null;
  }

  static Future<String?> updateTestimonial(FirebaseFirestore firestore, User admin, Testimonial updatedTestimonial) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('testimonials').doc(updatedTestimonial.id).update(updatedTestimonial.toMap());
    } catch (e) {}
    final index = dummyTestimonials.indexWhere((t) => t.id == updatedTestimonial.id);
    if (index != -1) {
      dummyTestimonials[index] = updatedTestimonial;
      _sortTestimonials();
    }
    return null;
  }

  static Future<String?> deleteTestimonial(FirebaseFirestore firestore, User admin, String testimonialId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('testimonials').doc(testimonialId).delete();
    } catch (e) {}
    dummyTestimonials.removeWhere((t) => t.id == testimonialId);
    return null;
  }

  static void _sortTestimonials() {
    dummyTestimonials.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // --- HERO SETTINGS ---

  static Future<String?> updateHeroSettings(FirebaseFirestore firestore, User admin, {required String subtitle, String? mediaPath, String? mediaType}) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      final batch = firestore.batch();
      batch.set(firestore.collection('siteSettings').doc('hero_subtitle'), {'key': 'hero_subtitle', 'value': subtitle, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      if (mediaPath != null) {
        batch.set(firestore.collection('siteSettings').doc('hero_media_path'), {'key': 'hero_media_path', 'value': mediaPath, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
        batch.set(firestore.collection('siteSettings').doc('hero_media_type'), {'key': 'hero_media_type', 'value': mediaType ?? 'image', 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {}

    // Update or insert subtitle
    final subIdx = dummySiteSettings.indexWhere((s) => s.key == 'hero_subtitle');
    if (subIdx != -1) {
      dummySiteSettings[subIdx] = SiteSetting(
        id: dummySiteSettings[subIdx].id, 
        key: 'hero_subtitle', 
        value: subtitle,
        createdAt: dummySiteSettings[subIdx].createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      dummySiteSettings.add(SiteSetting(
        id: 'hero_subtitle_\${DateTime.now().millisecondsSinceEpoch}',
        key: 'hero_subtitle', 
        value: subtitle,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    if (mediaPath != null) {
      final pathIdx = dummySiteSettings.indexWhere((s) => s.key == 'hero_media_path');
      if (pathIdx != -1) {
        dummySiteSettings[pathIdx] = SiteSetting(
          id: dummySiteSettings[pathIdx].id, 
          key: 'hero_media_path', 
          value: mediaPath,
          createdAt: dummySiteSettings[pathIdx].createdAt,
          updatedAt: DateTime.now(),
        );
      } else {
        dummySiteSettings.add(SiteSetting(
          id: 'hero_media_path_\${DateTime.now().millisecondsSinceEpoch}',
          key: 'hero_media_path', 
          value: mediaPath,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final typeIdx = dummySiteSettings.indexWhere((s) => s.key == 'hero_media_type');
      if (typeIdx != -1) {
        dummySiteSettings[typeIdx] = SiteSetting(
          id: dummySiteSettings[typeIdx].id, 
          key: 'hero_media_type', 
          value: mediaType ?? 'image',
          createdAt: dummySiteSettings[typeIdx].createdAt,
          updatedAt: DateTime.now(),
        );
      } else {
        dummySiteSettings.add(SiteSetting(
          id: 'hero_media_type_\${DateTime.now().millisecondsSinceEpoch}',
          key: 'hero_media_type', 
          value: mediaType ?? 'image',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }

    return null;
  }

  static Future<String?> removeHeroMedia(FirebaseFirestore firestore, User admin) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('siteSettings').doc('hero_media_path').delete(); 
      await firestore.collection('siteSettings').doc('hero_media_type').delete();
    } catch (e) {}
    dummySiteSettings.removeWhere((s) => s.key == 'hero_media_path' || s.key == 'hero_media_type');
    return null;
  }

  // --- QUOTES ---

  static Future<String?> markQuoteAddressed(FirebaseFirestore firestore, User admin, String quoteId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('quotes').doc(quoteId).update({'status': 'addressed'});
    } catch (e) {}
    final index = dummyQuoteRequests.indexWhere((q) => q.id == quoteId);
    if (index != -1) {
      dummyQuoteRequests[index] = dummyQuoteRequests[index].copyWith(status: 'addressed');
    }
    return null;
  }
}
''';

  var idx = content.indexOf('  // --- LANDING COLLECTIONS ---');
  content = content.substring(0, idx) + newBlock;
  file.writeAsStringSync(content);
}
