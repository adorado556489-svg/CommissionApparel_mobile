import '../models/user.dart';
import '../models/landing_collection.dart';
import '../models/testimonial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  
  static Future<String?> updateCoach(FirebaseFirestore firestore, User admin, User coach, {
    required String firstName,
    required String lastName,
    required String email,
    required String organization,
    required String phone,
    required String sport,
    required String status,
  }) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final qs = await firestore.collection('users').where('email', isEqualTo: email).get();
      if (qs.docs.isNotEmpty && qs.docs.first.id != coach.id) {
        return 'Email already in use.';
      }
      
      final doc = await firestore.collection('users').doc(coach.id).get();
      if (doc.exists) {
        await firestore.collection('users').doc(coach.id).update({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'organization': organization,
          'phone': phone,
          'sport': sport,
          'status': status,
        });
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static String? resetCoachPassword(User admin, User coach, String newPassword) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static Future<String?> deleteCoach(FirebaseFirestore firestore, User admin, String coachId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    try {
      await firestore.collection('users').doc(coachId).delete();
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static Future<String?> markDirectBatchAddressed(FirebaseFirestore firestore, User admin, String batchId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final qs = await firestore.collection('parentOrders').where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          if (doc.data()['teamStoreId'] == null) {
            batch.update(doc.reference, {'status': 'Processing', 'isArchived': true});

            // Notify parent
            final parentId = doc.data()['userId'];
            if (parentId != null) {
              final notifRef = firestore.collection('notifications').doc();
              batch.set(notifRef, {
                'userId': parentId,
                'type': 'order_processing',
                'title': 'Direct Order Processing',
                'message': 'Your direct order for ${doc.data()['athleteFirstName']} is now processing!',
                'readAt': null,
                'data': {'orderId': doc.id},
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
        await batch.commit();
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static Future<String?> markStoreBatchAddressed(FirebaseFirestore firestore, User admin, String batchId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final qs = await firestore.collection('parentOrders').where('batchId', isEqualTo: batchId).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          if (doc.data()['teamStoreId'] != null) {
            batch.update(doc.reference, {'status': 'Processing', 'isArchived': true});
            
            // Notify parent
            final parentId = doc.data()['userId'];
            if (parentId != null) {
              final notifRef = firestore.collection('notifications').doc();
              batch.set(notifRef, {
                'userId': parentId,
                'type': 'order_processing',
                'title': 'Order Processing',
                'message': 'Your order for ${doc.data()['athleteFirstName']} has been reviewed by the admin and is now processing!',
                'readAt': null,
                'data': {'orderId': doc.id},
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
        await batch.commit();
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static Future<String?> deleteArchivedOrderBatch(FirebaseFirestore firestore, User admin, String batchId) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    try {
      final qs = await firestore.collection('parentOrders').where('batchId', isEqualTo: batchId).where('isArchived', isEqualTo: true).get();
      if (qs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in qs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  static String? createLandingCollection(User admin, LandingCollection collection) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? updateLandingCollection(User admin, LandingCollection updatedCollection) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? deleteLandingCollection(User admin, String collectionId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? createTestimonial(User admin, Testimonial testimonial) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? updateTestimonial(User admin, Testimonial updatedTestimonial) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? deleteTestimonial(User admin, String testimonialId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? updateHeroSettings(User admin, {required String subtitle, String? mediaPath, String? mediaType}) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? removeHeroMedia(User admin) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? markQuoteAddressed(User admin, String quoteId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }
}
