import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'helpers/test_seeder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/theme.dart';
import 'fixtures/dummy_stores.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/screens/admin/admin_dashboard_screen.dart';

Widget createTestApp(Widget home, AuthService auth, [FirebaseFirestore? fs]) {
  fs ??= FakeFirebaseFirestore();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      Provider<FirebaseFirestore>.value(value: fs),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: home,
    ),
  );
}

/// Finds [text] only inside the open dialog (the page behind has buttons
/// with the same labels).
Finder inDialog(String text) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

/// Scrolls [finder] into view (lists are taller than the test viewport) and taps it.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  late FakeFirebaseFirestore firestore;
  late AuthService auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await TestSeeder.seedAll(firestore);

    auth = AuthService(firestore: firestore, firebaseAuth: MockFirebaseAuth(
        mockUser: MockUser(uid: 'user-admin-1', email: 'admin@commissionapparel.com'),
      ),
    );
    final s4Idx = rawdummyTeamStores.indexWhere((s) => s.id == 'store-4');
    if (s4Idx != -1) {
      rawdummyTeamStores[s4Idx] = rawdummyTeamStores[s4Idx].copyWith(status: 'pending');
    }
    final s1Idx = rawdummyTeamStores.indexWhere((s) => s.id == 'store-1');
    if (s1Idx != -1) {
      rawdummyTeamStores[s1Idx] = rawdummyTeamStores[s1Idx].copyWith(isArchived: false);
    }
  });

  Future<void> openDashboard(WidgetTester tester) async {
    await auth.login('admin@commissionapparel.com', 'password123');
    // Let the auth state listener publish the signed-in user.
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth, firestore));
    await tester.pumpAndSettle();
  }

  group('Admin store monitoring & approval', () {
    testWidgets('Dashboard shows monitoring tabs only (no merchant actions)', (tester) async {
      await openDashboard(tester);

      expect(find.textContaining('OVERVIEW'), findsOneWidget);
      expect(find.text('STORES'), findsOneWidget);
      expect(find.text('ORDERS'), findsOneWidget);
      expect(find.text('CATALOG'), findsOneWidget);

      // Merchant features must not exist on the admin side.
      expect(find.text('CAMPAIGN STORES'), findsNothing);
      expect(find.text('CREATE CAMPAIGN STORE'), findsNothing);
      expect(find.text('MANAGE STORE'), findsNothing);
      expect(find.text('COLLECTIONS'), findsNothing);

      expect(find.text('Pending School Store'), findsOneWidget);
    });

    testWidgets('Admin can approve a pending store (upgrades owner to coach)', (tester) async {
      await openDashboard(tester);

      expect(find.text('APPROVE'), findsOneWidget);
      await tapVisible(tester, find.text('APPROVE'));
      await tester.pumpAndSettle();
      await tester.tap(inDialog('CONFIRM'));
      await tester.pumpAndSettle();

      final doc = await firestore.collection('teamStores').doc('store-4').get();
      expect(doc.data()?['status'], 'approved');
      expect(doc.data()?['pricingApproved'], true);
      expect(doc.data()?['isArchived'], false);

      final owner = await firestore.collection('users').doc(doc.data()?['userId'] as String).get();
      expect(owner.data()?['role'], 'coach');
    });

    testWidgets('Admin can decline a pending store with a reason', (tester) async {
      await openDashboard(tester);

      await tapVisible(tester, find.text('DECLINE'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Incomplete team details');
      await tester.tap(inDialog('DECLINE'));
      await tester.pumpAndSettle();

      final doc = await firestore.collection('teamStores').doc('store-4').get();
      expect(doc.data()?['status'], 'declined');
      expect(doc.data()?['declineReason'], 'Incomplete team details');
    });

    testWidgets('Admin can suspend and restore a store', (tester) async {
      await openDashboard(tester);

      await tester.tap(find.text('STORES'));
      await tester.pumpAndSettle();

      Future<int> archivedCount() async => (await firestore
              .collection('teamStores')
              .where('isArchived', isEqualTo: true)
              .get())
          .docs
          .length;

      final before = await archivedCount();

      await tapVisible(tester, find.text('SUSPEND').first);
      await tester.pumpAndSettle();
      await tester.tap(inDialog('SUSPEND'));
      await tester.pumpAndSettle();
      expect(await archivedCount(), before + 1);
      expect(find.text('RESTORE'), findsWidgets);

      await tapVisible(tester, find.text('RESTORE').first);
      await tester.pumpAndSettle();
      await tester.tap(inDialog('RESTORE'));
      await tester.pumpAndSettle();
      expect(await archivedCount(), before);
    });
  });
}
