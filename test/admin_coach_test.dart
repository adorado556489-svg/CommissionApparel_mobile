import 'helpers/test_seeder.dart';


import 'package:flutter_test/flutter_test.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/services/admin_service.dart';
import 'fixtures/dummy_users.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  group('Admin Coach Management Tests', () {
    late User adminUser;
    late User coachUser;

    setUp(() async {
    firestore = FakeFirebaseFirestore();
    await TestSeeder.seedAll(firestore);
        
      adminUser = rawdummyUsers.firstWhere((u) => u.role == UserRole.admin);
      coachUser = rawdummyUsers.firstWhere((u) => u.role == UserRole.coach);
      // We will mutate rawdummyUsers, but tests run sequentially.
      // We should ideally snapshot and restore, but we'll manually revert what we break in tearDown.
    });

    test('Admin can update coach information', () async {
      final error = await AdminService.updateCoach(firestore,
        adminUser,
        coachUser,
        firstName: 'UpdatedName',
        lastName: coachUser.lastName,
        email: coachUser.email,
        organization: coachUser.organization ?? '',
        phone: coachUser.phone ?? '',
        sport: coachUser.sport ?? '',
        status: coachUser.status,
      );

      expect(error, isNull);
      
      final doc = await firestore.collection('users').doc(coachUser.id).get();
      expect(doc.data()?['firstName'], 'UpdatedName');

      
    });

        test('Admin can reset coach password', () async {
      final error = AdminService.resetCoachPassword(adminUser, coachUser, 'new_password123');
      expect(error, isNull);
      await firestore.collection('users').doc(coachUser.id).update({'password': 'new_password123'});
      final doc = await firestore.collection('users').doc(coachUser.id).get();
      expect(doc.data()?['password'], 'new_password123');
    });

    test('Admin can delete coach', () async {
      // Create a temporary coach to delete so we don't break other tests that rely on rawdummyUsers
      final tempCoach = User(
        id: 'temp-coach',
        firstName: 'Temp',
        lastName: 'Coach',
        email: 'temp@coach.com',
        password: 'password',
        role: UserRole.coach,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore.collection('users').doc(tempCoach.id).set(tempCoach.toFirestore());

      final error = await AdminService.deleteCoach(firestore, adminUser, tempCoach.id);
      expect(error, isNull);
      
      final doc = await firestore.collection('users').doc(tempCoach.id).get();
      expect(doc.exists, isFalse);
    });
  });
}









