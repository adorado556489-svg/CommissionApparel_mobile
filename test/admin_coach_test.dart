import 'package:flutter_test/flutter_test.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/services/admin_service.dart';
import 'package:commission_apparel_flutter/data/dummy_users.dart';

void main() {
  group('Admin Coach Management Tests', () {
    late User adminUser;
    late User coachUser;

    setUp(() {
      adminUser = dummyUsers.firstWhere((u) => u.role == UserRole.admin);
      coachUser = dummyUsers.firstWhere((u) => u.role == UserRole.coach);
      // We will mutate dummyUsers, but tests run sequentially.
      // We should ideally snapshot and restore, but we'll manually revert what we break in tearDown.
    });

    test('Admin can update coach information', () async {
      final originalFirstName = coachUser.firstName;

      final error = await AdminService.updateCoach(
        FakeFirebaseFirestore(),
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
      
      final updatedCoach = dummyUsers.firstWhere((u) => u.id == coachUser.id);
      expect(updatedCoach.firstName, 'UpdatedName');

      // Revert
      await AdminService.updateCoach(
        FakeFirebaseFirestore(),
        adminUser,
        updatedCoach,
        firstName: originalFirstName,
        lastName: updatedCoach.lastName,
        email: updatedCoach.email,
        organization: updatedCoach.organization ?? '',
        phone: updatedCoach.phone ?? '',
        sport: updatedCoach.sport ?? '',
        status: updatedCoach.status,
      );
    });

    test('Admin can reset coach password', () {
      final originalPassword = coachUser.password;

      final error = AdminService.resetCoachPassword(adminUser, coachUser, 'new_password123');
      expect(error, isNull);

      final updatedCoach = dummyUsers.firstWhere((u) => u.id == coachUser.id);
      expect(updatedCoach.password, 'new_password123');

      // Revert
      AdminService.resetCoachPassword(adminUser, updatedCoach, originalPassword);
    });

    test('Admin can delete coach', () async {
      // Create a temporary coach to delete so we don't break other tests that rely on dummyUsers
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
      dummyUsers.add(tempCoach);

      final error = await AdminService.deleteCoach(FakeFirebaseFirestore(), adminUser, tempCoach.id);
      expect(error, isNull);
      
      final exists = dummyUsers.any((u) => u.id == tempCoach.id);
      expect(exists, isFalse);
    });
  });
}


