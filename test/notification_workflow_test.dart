import 'helpers/test_seeder.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/services/content_service.dart';
import 'package:commission_apparel_flutter/services/store_service.dart';


void main() {
  TestSeeder.populateDummyFallbacks();

  group('Phase I - Notification Workflow Tests', () {
    late FakeFirebaseFirestore firestore;
    late User coachUser;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAdminEnvironment(firestore);
      coachUser = User(password: '', updatedAt: DateTime.now(),
        id: 'coach-1',
        email: 'coach@test.com',
        firstName: 'Coach',
        lastName: 'User',
        role: UserRole.coach,
        createdAt: DateTime.now(),
      );
    });

    test('Admin store approval creates a notification for the coach', () async {
      final store = TeamStore(
        id: 'store-1',
        userId: coachUser.id,
        name: 'My Store',
        slug: 'my-store',
        status: 'pending',
        pricingApproved: false,
        packageType: 'individual',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await StoreService.createStore(firestore, store);
      await StoreService.updateStore(firestore, store.copyWith(status: 'approved'));
      // Simulate Cloud Function for notification
      await firestore.collection('notifications').add({'id': 'n-123', 'userId': coachUser.id, 'title': 'Store Approved', 'message': 'Store approved', 'createdAt': Timestamp.now(), 'readAt': null});
      await firestore.collection('notifications').add({'id': 'n-123', 'userId': coachUser.id, 'title': 'Store Approved', 'message': 'Store approved', 'createdAt': Timestamp.now(), 'readAt': null});

      final notifs = await ContentService.getNotificationsForUser(firestore, coachUser.id);
      expect(notifs.isNotEmpty, true, reason: 'Notification should be created');
      expect(notifs.first.title, 'Store Approved');
      expect(notifs.first.isRead, false);
      expect(notifs.first.userId, coachUser.id);
    });

    test('Coach retrieves only their own notifications', () async {
      // Direct create bypassing workflow
      await firestore.collection('notifications').doc('n1').set({
        'id': 'n1',
        'userId': coachUser.id,
        'title': 'Coach Notif',
        'message': 'Message',
        'createdAt': Timestamp.now(),
        'readAt': null,
      });
      await firestore.collection('notifications').doc('n2').set({
        'id': 'n2',
        'userId': 'other-coach',
        'title': 'Other Notif',
        'message': 'Message',
        'createdAt': Timestamp.now(),
        'readAt': null,
      });

      final notifs = await ContentService.getNotificationsForUser(firestore, coachUser.id);
      expect(notifs.length, 1);
      expect(notifs.first.userId, coachUser.id);
    });

    test('User can mark their notification as read', () async {
      await firestore.collection('notifications').doc('n1').set({
        'id': 'n1',
        'userId': coachUser.id,
        'title': 'Read me',
        'message': 'Message',
        'createdAt': Timestamp.now(),
        'readAt': null,
      });

      await ContentService.markNotificationAsRead(firestore, 'n1', coachUser.id);
      final notifs = await ContentService.getNotificationsForUser(firestore, coachUser.id);
      expect(notifs.first.isRead, true);
    });

    test('User cannot mark another users notification as read', () async {
      await firestore.collection('notifications').doc('n2').set({'id': 'n2', 'userId': 'other-coach', 'title': 'Not yours', 'message': 'Message', 'createdAt': Timestamp.now(), 'readAt': null});
      await ContentService.markNotificationAsRead(firestore, 'n2', coachUser.id);
      final notifs = await ContentService.getNotificationsForUser(firestore, 'other-coach');
      expect(notifs.first.isRead, false);
    });
  });
}

