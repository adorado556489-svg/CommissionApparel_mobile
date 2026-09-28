import 'package:cloud_firestore/cloud_firestore.dart';
import '../fixtures/dummy_users.dart';
import '../fixtures/dummy_stores.dart';
import '../fixtures/dummy_catalog.dart';
import '../fixtures/dummy_orders.dart';
import '../fixtures/dummy_content.dart';
import '../fixtures/dummy_quotes.dart';

class TestSeeder {
  static Future<void> populate(dynamic db) async {
    await seedAll(db);
  }
  static void populateDummyFallbacks() {}
  
  static Future<void> seedAdminEnvironment(dynamic firestore) async {
    await seedAll(firestore);
  }
  
  static Future<void> seedAll(dynamic firestore) async {
    for (var u in rawdummyUsers) {
      await firestore.collection('users').doc(u.id).set(u.toFirestore());
    }
    for (var s in rawdummyTeamStores) {
      await firestore.collection('teamStores').doc(s.id).set(s.toFirestore());
    }
    for (var i in rawdummyStoreItems) {
      await firestore.collection('storeItems').doc(i.id).set(i.toFirestore());
    }
    for (var o in rawdummyParentOrders) {
      await firestore.collection('parentOrders').doc(o.id).set(o.toFirestore());
    }
    for (var d in rawdummyDesignCatalog) {
      await firestore.collection('designCatalog').doc(d.id).set(d.toFirestore());
    }
    for (var c in rawdummyDesignCollections) {
      await firestore.collection('designCollections').doc(c.id).set(c.toFirestore());
    }
    for (var l in rawdummyLandingCollections) {
      await firestore.collection('landingCollections').doc(l.id).set(l.toFirestore());
    }
    for (var t in rawdummyTestimonials) {
      await firestore.collection('testimonials').doc(t.id).set(t.toFirestore());
    }
    for (var ss in rawdummySiteSettings) {
      await firestore.collection('siteSettings').doc(ss.id).set(ss.toFirestore());
    }
    for (var q in rawdummyQuoteRequests) {
      await firestore.collection('quoteRequests').doc(q.id).set(q.toFirestore());
    }
  }

  static Future<void> seedCoachStoreEnvironment(dynamic firestore) async {
    await seedAll(firestore);
  }

  static Future<void> seedParentEnvironment(dynamic firestore) async {
    await seedAll(firestore);
  }
}
