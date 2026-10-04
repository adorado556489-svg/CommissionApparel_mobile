import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'helpers/test_seeder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/theme.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/services/order_service.dart';
import 'package:commission_apparel_flutter/screens/coach/coach_dashboard_screen.dart';

Widget createTestApp(
  Widget home,
  AuthService auth,
  FirebaseFirestore firestore,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      Provider<FirebaseFirestore>.value(value: firestore),
    ],
    child: MaterialApp(theme: AppTheme.darkTheme, home: home),
  );
}

void main() {
  late AuthService auth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    await TestSeeder.seedAll(fakeFirestore);
  });

  /// Signs in as [uid]/[email] and opens the coach dashboard.
  Future<void> openDashboardAs(
    WidgetTester tester,
    String uid,
    String email,
  ) async {
    auth = AuthService(
      firestore: fakeFirestore,
      firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: uid, email: email)),
    );
    await auth.login(email, 'password123');
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpWidget(
      createTestApp(const CoachDashboardScreen(), auth, fakeFirestore),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    final tab = find.descendant(
      of: find.byType(TabBar),
      matching: find.textContaining(label),
    );
    await tester.ensureVisible(tab); // scrollable tab bar on narrow screens
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }

  /// Scrolls the visible tab's list until [finder] is built and on screen
  /// (lists build lazily, so off-screen widgets do not exist yet).
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    final scrollable = find
        .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(finder, 300, scrollable: scrollable);
    await tester.pumpAndSettle();
  }

  group('Phase 5A - Coach Store Functionality', () {
    testWidgets('Coach with a store sees all management tabs', (tester) async {
      await openDashboardAs(tester, 'user-coach-1', 'coach@example.com');

      expect(find.text('REQUEST A TEAM STORE'), findsNothing);
      for (final tab in ['STORE', 'PRODUCTS', 'COLLECTIONS', 'ORDERS', 'EARNINGS']) {
        expect(
          find.descendant(of: find.byType(TabBar), matching: find.textContaining(tab)),
          findsOneWidget,
          reason: 'missing tab $tab',
        );
      }
      expect(find.text('Riverside Academy Basketball'), findsWidgets);
    });

    testWidgets('Coach without a store is invited to request one', (tester) async {
      await openDashboardAs(tester, 'user-coach-3', 'david.chen@trackclub.org');

      expect(find.text('REQUEST A TEAM STORE'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('Coach can set the order deadline', (tester) async {
      await openDashboardAs(tester, 'user-coach-1', 'coach@example.com');

      final button = find.textContaining('DATE');
      await scrollTo(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final stores = await fakeFirestore
          .collection('teamStores')
          .where('userId', isEqualTo: 'user-coach-1')
          .get();
      expect(stores.docs.first.data()['orderDeadline'], isNotNull);
      expect(find.textContaining('Order deadline set to'), findsOneWidget);
    });

    testWidgets('Empty roster cannot be submitted', (tester) async {
      await openDashboardAs(tester, 'user-coach-2', 'sarah.williams@school.edu');
      await openTab(tester, 'ORDERS');

      final submit = find.text('SUBMIT MASTER ORDER');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('No unbatched orders to submit.'), findsOneWidget);
    });

    testWidgets('Valid unbatched orders can be submitted; locks the store', (tester) async {
      await openDashboardAs(tester, 'user-coach-1', 'coach@example.com');
      await openTab(tester, 'ORDERS');

      final submit = find.textContaining('SUBMIT MASTER ORDER');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('Submit master order?'), findsOneWidget);
      await tester.tap(
        find.descendant(of: find.byType(AlertDialog), matching: find.text('SUBMIT')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Master order submitted successfully!'), findsOneWidget);

      final store = await fakeFirestore
          .collection('teamStores')
          .where('userId', isEqualTo: 'user-coach-1')
          .get();
      expect(store.docs.first.data()['status'], 'submitted_to_admin');

      final orders = await fakeFirestore
          .collection('parentOrders')
          .where('teamStoreId', isEqualTo: store.docs.first.id)
          .get();
      final submitted = orders.docs.where((d) => d.data()['batchId'] != null);
      expect(submitted, isNotEmpty);
      for (final d in submitted) {
        expect(d.data()['status'], 'Submitted to Admin');
      }

      // The STORE tab now offers to re-open the store.
      await openTab(tester, 'STORE');
      await scrollTo(tester, find.text('RE-OPEN STORE'));
      expect(find.text('RE-OPEN STORE'), findsOneWidget);
    });

    testWidgets('Every tab renders on a small phone without layout errors', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await openDashboardAs(tester, 'user-coach-1', 'coach@example.com');
      for (final tab in ['PRODUCTS', 'COLLECTIONS', 'ORDERS', 'EARNINGS', 'STORE']) {
        await openTab(tester, tab);
        expect(tester.takeException(), isNull, reason: 'layout error on $tab tab');
      }
    });

    test('Coach can mark an order paid and unpaid', () async {
      final orders = await OrderService.getOrdersForStore(
        fakeFirestore,
        (await fakeFirestore
                .collection('teamStores')
                .where('userId', isEqualTo: 'user-coach-1')
                .get())
            .docs
            .first
            .id,
      );
      expect(orders, isNotEmpty);
      final id = orders.first.id;

      expect(await OrderService.setOrderPaid(fakeFirestore, id, true), isNull);
      expect((await fakeFirestore.collection('parentOrders').doc(id).get()).data()?['isPaid'], true);
      expect(await OrderService.setOrderPaid(fakeFirestore, id, false), isNull);
      expect((await fakeFirestore.collection('parentOrders').doc(id).get()).data()?['isPaid'], false);
    });

    test(
      'Store live/accepting-order rules match the Laravel behavior exactly',
      () {
        final store = TeamStore(
          id: 'test',
          userId: 'coach',
          name: 'test',
          slug: 'test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(store.status, 'pending');
        expect(store.isLive, false);
        expect(store.closedReason, 'not_active');

        var s2 = store.copyWith(status: 'approved');
        expect(s2.isLive, false);
        expect(s2.closedReason, 'pricing_review');

        var s3 = s2.copyWith(pricingApproved: true);
        expect(s3.isLive, true);
        expect(s3.closedReason, null);
        expect(s3.isAcceptingOrders, true);

        var s4 = s3.copyWith(
          orderDeadline: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(s4.isLive, false);
        expect(s4.closedReason, 'deadline_passed');
        expect(s4.isAcceptingOrders, false);

        var s5 = s3.copyWith(status: 'submitted_to_admin');
        expect(s5.isLive, false);
        expect(s5.closedReason, 'submitted_to_admin');

        var s6 = s3.copyWith(isArchived: true);
        expect(s6.isLive, false);
        expect(s6.closedReason, 'archived');
      },
    );
  });
}
