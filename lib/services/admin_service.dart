import '../models/user.dart';

import '../models/landing_collection.dart';
import '../models/testimonial.dart';

import '../models/site_setting.dart';
import '../data/dummy_users.dart';
import '../data/dummy_stores.dart';
import '../data/dummy_orders.dart';
import '../data/dummy_content.dart';
import '../data/dummy_quotes.dart';


class AdminService {
  
  // --- COACH MANAGEMENT ---

  static String? updateCoach(User admin, User coach, {
    required String firstName,
    required String lastName,
    required String email,
    required String organization,
    required String phone,
    required String sport,
    required String status,
  }) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index == -1) return 'Coach not found';

    // check email uniqueness
    if (dummyUsers.any((u) => u.email == email && u.id != coach.id)) {
      return 'Email already in use.';
    }

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
    return null;
  }

  static String? resetCoachPassword(User admin, User coach, String newPassword) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    if (newPassword.length < 8) return 'Password must be at least 8 characters.';
    
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index == -1) return 'Coach not found';

    dummyUsers[index] = dummyUsers[index].copyWith(
      password: newPassword,
      updatedAt: DateTime.now(),
    );
    return null;
  }

  static String? deleteCoach(User admin, String coachId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    final index = dummyUsers.indexWhere((u) => u.id == coachId);
    if (index == -1) return 'Coach not found';

    final coachStoreIds = dummyTeamStores.where((s) => s.userId == coachId).map((s) => s.id).toSet();

    dummyParentOrders.removeWhere((o) => o.teamStoreId != null && coachStoreIds.contains(o.teamStoreId));
    dummyParentOrders.removeWhere((o) => o.teamStoreId == null && o.userId == coachId);
    dummyTeamStores.removeWhere((s) => s.userId == coachId);
    dummyUsers.removeAt(index);
    
    return null;
  }

  // --- BATCH MANAGEMENT ---

  static String? markDirectBatchAddressed(User admin, String batchId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    var found = false;
    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.batchId == batchId && o.teamStoreId == null) {
        dummyParentOrders[i] = o.copyWith(status: 'Processing', isArchived: true);
        found = true;
      }
    }
    return found ? null : 'Batch not found.';
  }

  static String? markStoreBatchAddressed(User admin, String batchId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    var found = false;
    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.batchId == batchId && o.teamStoreId != null) {
        dummyParentOrders[i] = o.copyWith(status: 'Processing', isArchived: true);
        found = true;
      }
    }
    return found ? null : 'Batch not found.';
  }

  static String? deleteArchivedOrderBatch(User admin, String batchId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    final initialLength = dummyParentOrders.length;
    dummyParentOrders.removeWhere((o) => o.batchId == batchId && o.isArchived);
    
    if (dummyParentOrders.length == initialLength) {
      return 'Archived order batch not found.';
    }
    return null;
  }

  // --- LANDING COLLECTIONS ---

  static String? createLandingCollection(User admin, LandingCollection collection) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummyLandingCollections.add(collection);
    _sortLandingCollections();
    return null;
  }

  static String? updateLandingCollection(User admin, LandingCollection updatedCollection) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final index = dummyLandingCollections.indexWhere((c) => c.id == updatedCollection.id);
    if (index == -1) return 'Collection not found';
    
    dummyLandingCollections[index] = updatedCollection;
    _sortLandingCollections();
    return null;
  }

  static String? deleteLandingCollection(User admin, String collectionId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummyLandingCollections.removeWhere((c) => c.id == collectionId);
    return null;
  }

  static void _sortLandingCollections() {
    dummyLandingCollections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // --- TESTIMONIALS ---

  static String? createTestimonial(User admin, Testimonial testimonial) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummyTestimonials.add(testimonial);
    _sortTestimonials();
    return null;
  }

  static String? updateTestimonial(User admin, Testimonial updatedTestimonial) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final index = dummyTestimonials.indexWhere((t) => t.id == updatedTestimonial.id);
    if (index == -1) return 'Testimonial not found';
    
    dummyTestimonials[index] = updatedTestimonial;
    _sortTestimonials();
    return null;
  }

  static String? deleteTestimonial(User admin, String testimonialId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummyTestimonials.removeWhere((t) => t.id == testimonialId);
    return null;
  }

  static void _sortTestimonials() {
    dummyTestimonials.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // --- HERO SETTINGS ---

  static String? updateHeroSettings(User admin, {required String subtitle, String? mediaPath, String? mediaType}) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
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
        id: 'hero_subtitle_${DateTime.now().millisecondsSinceEpoch}',
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
          id: 'hero_media_path_${DateTime.now().millisecondsSinceEpoch}',
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
          id: 'hero_media_type_${DateTime.now().millisecondsSinceEpoch}',
          key: 'hero_media_type', 
          value: mediaType ?? 'image',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }

    return null;
  }

  static String? removeHeroMedia(User admin) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    dummySiteSettings.removeWhere((s) => s.key == 'hero_media_path' || s.key == 'hero_media_type');
    return null;
  }

  // --- QUOTES ---

  static String? markQuoteAddressed(User admin, String quoteId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    final index = dummyQuoteRequests.indexWhere((q) => q.id == quoteId);
    if (index == -1) return 'Quote not found';

    dummyQuoteRequests[index] = dummyQuoteRequests[index].copyWith(status: 'addressed');
    return null;
  }
}


