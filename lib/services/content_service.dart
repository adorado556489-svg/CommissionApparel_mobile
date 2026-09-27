import 'dummy_fallbacks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/site_setting.dart';
import '../models/testimonial.dart';


import '../models/notification_item.dart';
import '../constants/firestore_paths.dart';
import '../models/landing_collection.dart';
import '../models/quote_request.dart';

class ContentService {
  static void _handleError(Object e, String contextMessage) {
    if (e is FirebaseException) {
      if (e.code == 'not-found' || e.code == 'unimplemented') {
        return; // Expected missing data
      }
      print('CRITICAL FIRESTORE ERROR [$contextMessage]: [${e.plugin}/${e.code}] ${e.message}');
      throw e;
    }
    throw e;
  }

  // --- SITE SETTINGS ---

  static Future<List<SiteSetting>> getSiteSettings(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.siteSettings).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => SiteSetting.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'ContentService.getSiteSettings');
    }
    return [];
  }

  static Future<void> updateSiteSetting(FirebaseFirestore firestore, SiteSetting setting) async {
    try {
      await firestore.collection(FirestorePaths.siteSettings).doc(setting.id).set(setting.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      _handleError(e, 'ContentService.updateSiteSetting');
    }
  }

  // --- TESTIMONIALS ---

  static Future<List<Testimonial>> getAllTestimonials(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.testimonials).orderBy('sortOrder').get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => Testimonial.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'ContentService.getAllTestimonials');
    }
    return [];
  }

  static Future<void> createTestimonial(FirebaseFirestore firestore, Testimonial testimonial) async {
    try {
      await firestore.collection(FirestorePaths.testimonials).doc(testimonial.id).set(testimonial.toFirestore());
    } catch (e) {
      _handleError(e, 'ContentService.createTestimonial');
    }
  }

  static Future<void> updateTestimonial(FirebaseFirestore firestore, Testimonial testimonial) async {
    try {
      await firestore.collection(FirestorePaths.testimonials).doc(testimonial.id).update(testimonial.toFirestore());
    } catch (e) {
      _handleError(e, 'ContentService.updateTestimonial');
    }
  }

  static Future<void> deleteTestimonial(FirebaseFirestore firestore, String id) async {
    try {
      await firestore.collection(FirestorePaths.testimonials).doc(id).delete();
    } catch (e) {
      _handleError(e, 'ContentService.deleteTestimonial');
    }
  }

  // --- LANDING COLLECTIONS ---

  static Future<List<LandingCollection>> getAllLandingCollections(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.landingCollections).orderBy('sortOrder').get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => LandingCollection.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'ContentService.getAllLandingCollections');
    }
    return [];
  }

  // --- QUOTE REQUESTS ---

  static Future<List<QuoteRequest>> getAllQuoteRequests(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.quoteRequests).orderBy('createdAt', descending: true).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => QuoteRequest.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'ContentService.getAllQuoteRequests');
    }
    return [];
  }

  static Future<void> createQuoteRequest(FirebaseFirestore firestore, QuoteRequest quote) async {
    try {
      await firestore.collection(FirestorePaths.quoteRequests).doc(quote.id).set(quote.toFirestore());
    } catch (e) {
      _handleError(e, 'ContentService.createQuoteRequest');
    }
  }

  static Future<void> updateQuoteRequestStatus(FirebaseFirestore firestore, String quoteId, String status) async {
    try {
      await firestore.collection(FirestorePaths.quoteRequests).doc(quoteId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _handleError(e, 'ContentService.updateQuoteRequestStatus');
    }
  }

  // --- NOTIFICATIONS ---
  
    static Stream<List<NotificationItem>> getUserNotificationsStream(FirebaseFirestore firestore, String userId) {
    return firestore
        .collection(FirestorePaths.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((qs) {
          if (qs.docs.isEmpty) {
            return [];
          }
          return qs.docs.map((d) => NotificationItem.fromFirestore(d)).toList();
        });
  }

  static Future<List<NotificationItem>> getUserNotifications(FirebaseFirestore firestore, String userId) async {
    try {
      final qs = await firestore.collection(FirestorePaths.notifications)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => NotificationItem.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'ContentService.getUserNotifications');
    }
      return [];
  }

  static Future<void> createNotification(FirebaseFirestore firestore, NotificationItem notification) async {
    try {
      await firestore.collection(FirestorePaths.notifications).doc(notification.id).set(notification.toFirestore());
    } catch (e) {
      _handleError(e, 'ContentService.createNotification');
    }
  }

  static Future<void> markNotificationRead(FirebaseFirestore firestore, String notificationId, String userId) async {
    try {
      final doc = await firestore.collection(FirestorePaths.notifications).doc(notificationId).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        await firestore.collection(FirestorePaths.notifications).doc(notificationId).update({'readAt': FieldValue.serverTimestamp()});
      } else if (doc.exists) {
        throw FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied', message: 'Unauthorized');
      }
    } catch (e) {
      _handleError(e, 'ContentService.markNotificationRead');
    }





}}
