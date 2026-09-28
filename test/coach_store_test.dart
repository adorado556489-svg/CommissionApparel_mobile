
import 'helpers/auto_seeding_mock_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/theme.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'fixtures/dummy_users.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/screens/coach/coach_dashboard_screen.dart';

Widget createTestApp(Widget home, AuthService auth) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      Provider<FirebaseFirestore>.value(value: FakeFirebaseFirestore()),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: home,
    ),
  );
}

void main() {
  late AuthService auth;

  setUp(() {
    auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
    final idx = dummyUsers.indexWhere((u) => u.email == 'david.chen@trackclub.org');
    if (idx != -1) {
      dummyUsers[idx] = dummyUsers[idx].copyWith(status: 'active');
    }
  });

  group('Phase 5A - Coach Store Functionality', () {
    testWidgets('Coach with existing store sees dashboard (cannot create another)', (tester) async {
      await auth.login('coach@example.com', 'password123'); // Marcus
      await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth));
      await tester.pumpAndSettle();

      expect(find.text('Create Team Store'), findsNothing);
      expect(find.text('Riverside Academy Basketball'), findsOneWidget);
    });

    testWidgets('Coach without store can create a store', (tester) async {
      await auth.login('david.chen@trackclub.org', 'password123'); // David Chen
      await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth));
      await tester.pumpAndSettle();

      expect(find.text('Create Team Store'), findsOneWidget);
      
      await tester.enterText(find.byType(TextField).first, 'David Track Store');
      await tester.enterText(find.byType(TextField).last, 'Track and field gear');
      await tester.tap(find.text('REQUEST STORE'));
      await tester.pumpAndSettle();
      
      expect(find.text('Create Team Store'), findsNothing);
      expect(find.text('David Track Store'), findsOneWidget);
    });

    testWidgets('Coach can set deadline', (tester) async {
      await auth.login('david.chen@trackclub.org', 'password123');
      await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth));
      await tester.pumpAndSettle();

      expect(find.text('CHANGE DATE'), findsOneWidget);
      await tester.tap(find.text('CHANGE DATE'));
      await tester.pumpAndSettle();
      
      expect(find.text('OK'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('Coach can add assigned DesignCatalog item', (tester) async {
      await auth.login('david.chen@trackclub.org', 'password123');
      await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_circle), findsWidgets);
      await tester.ensureVisible(find.byIcon(Icons.add_circle).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_circle).first);
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.delete), findsWidgets);
    });

    testWidgets('Coach cannot set retail price below wholesale; can set valid retail pricing', (tester) async {
      await auth.login('coach@example.com', 'password123');
      await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      await tester.enterText(textFields.first, '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Retail price cannot be less than wholesale price.'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 4));

      await tester.enterText(textFields.first, '999.0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Retail price cannot be less than wholesale price.'), findsNothing);
    });

    testWidgets('Empty roster cannot be submitted', (tester) async {
      await auth.login('david.chen@trackclub.org', 'password123'); // David has no orders
      await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SUBMIT MASTER ORDER'));
      await tester.pumpAndSettle();
      expect(find.text('Cannot submit an empty roster.'), findsOneWidget);
    });

    testWidgets('Valid unbatched orders can be submitted; locks the store', (tester) async {
      await auth.login('coach@example.com', 'password123'); // Marcus has unbatched order-1
      await tester.pumpWidget(createTestApp(const CoachDashboardScreen(), auth));
      await tester.pumpAndSettle();

      expect(find.textContaining('Unbatched Orders:'), findsOneWidget);
      
      await tester.tap(find.text('SUBMIT MASTER ORDER'));
      await tester.pumpAndSettle();
      
      expect(find.text('Master order submitted successfully!'), findsOneWidget);
      
      expect(find.text('LOCKED'), findsOneWidget);
      expect(find.text('MASTER ORDER SUBMITTED'), findsOneWidget);
    });
    
    test('Store live/accepting-order rules match the Laravel behavior exactly', () {
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
      
      var s4 = s3.copyWith(orderDeadline: DateTime.now().subtract(const Duration(days: 1)));
      expect(s4.isLive, false);
      expect(s4.closedReason, 'deadline_passed');
      expect(s4.isAcceptingOrders, false);
      
      var s5 = s3.copyWith(status: 'submitted_to_admin');
      expect(s5.isLive, false);
      expect(s5.closedReason, 'submitted_to_admin');
      
      var s6 = s3.copyWith(isArchived: true);
      expect(s6.isLive, false);
      expect(s6.closedReason, 'archived');
    });

  });
}





