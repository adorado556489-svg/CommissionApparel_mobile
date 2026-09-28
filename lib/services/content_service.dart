import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/site_setting.dart';
import '../models/testimonial.dart';
import '../models/landing_collection.dart';
import '../models/quote_request.dart';
import '../models/notification_item.dart';
import '../constants/firestore_paths.dart';
import 'package:flutter/foundation.dart';

class ContentService {
  static void _handleError(Object e, String context) {
    if (e is FirebaseException && (e.code == 'not-found' || e.code == 'unimplemented')) return;
    debugPrint('CRITICAL FIRESTORE ERROR [$context]: $e');
    throw e;
  }

  static Future<List<SiteSetting>> getAllSiteSettings(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.siteSettings).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => SiteSetting.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "ContentService"); }
    return [];
  }

  static Future<List<Testimonial>> getAllTestimonials(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.testimonials).orderBy('sortOrder').get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => Testimonial.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "ContentService"); }
    return [];
  }

  static Future<List<LandingCollection>> getAllLandingCollections(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.landingCollections).orderBy('sortOrder').get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => LandingCollection.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "ContentService"); }
    return [];
  }

  static Future<List<QuoteRequest>> getAllQuoteRequests(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.quoteRequests).orderBy('createdAt', descending: true).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => QuoteRequest.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "ContentService"); }
    return [];
  }

    static Stream<List<NotificationItem>> getUserNotificationsStream(FirebaseFirestore firestore, String userId) {
    return firestore
        .collection(FirestorePaths.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) => NotificationItem.fromFirestore(d)).toList());
  }

  static Future<List<NotificationItem>> getNotificationsForUser(FirebaseFirestore firestore, String userId) async {
    try {
      final qs = await firestore.collection(FirestorePaths.notifications)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => NotificationItem.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "ContentService"); }
    return [];
  }

  static Future<void> markNotificationAsRead(FirebaseFirestore firestore, String notificationId, String userId) async {
    try {
      final doc = await firestore.collection(FirestorePaths.notifications).doc(notificationId).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        await firestore.collection(FirestorePaths.notifications).doc(notificationId).update({'readAt': FieldValue.serverTimestamp()});
      }
    } catch (e) { _handleError(e, "ContentService"); }
  }

  static Future<void> createSiteSetting(FirebaseFirestore firestore, SiteSetting setting) async {
    try {
      await firestore.collection(FirestorePaths.siteSettings).doc(setting.id).set(setting.toFirestore());
    } catch (e) { _handleError(e, "ContentService"); }
  }

  static Future<void> updateSiteSetting(FirebaseFirestore firestore, SiteSetting setting) async {
    try {
      await firestore.collection(FirestorePaths.siteSettings).doc(setting.id).update(setting.toFirestore());
    } catch (e) { _handleError(e, "ContentService"); }
  }

  static Future<void> deleteSiteSetting(FirebaseFirestore firestore, String settingId) async {
    try {
      await firestore.collection(FirestorePaths.siteSettings).doc(settingId).delete();
    } catch (e) { _handleError(e, "ContentService"); }
  }

  static Future<void> createTestimonial(FirebaseFirestore firestore, Testimonial testimonial) async {
    try {
      await firestore.collection(FirestorePaths.testimonials).doc(testimonial.id).set(testimonial.toFirestore());
    } catch (e) { _handleError(e, "ContentService"); }
  }

  static Future<void> updateTestimonial(FirebaseFirestore firestore, Testimonial testimonial) async {
    try {
      await firestore.collection(FirestorePaths.testimonials).doc(testimonial.id).update(testimonial.toFirestore());
    } catch (e) { _handleError(e, "ContentService"); }
  }

  static Future<void> deleteTestimonial(FirebaseFirestore firestore, String testimonialId) async {
    try {
      await firestore.collection(FirestorePaths.testimonials).doc(testimonialId).delete();
    } catch (e) { _handleError(e, "ContentService"); }
  }
}
