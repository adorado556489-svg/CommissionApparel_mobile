
import 'helpers/auto_seeding_mock_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/theme.dart';
import 'fixtures/dummy_stores.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/screens/admin/admin_dashboard_screen.dart';
import 'package:commission_apparel_flutter/screens/admin/admin_store_edit_screen.dart';

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
    final s4Idx = dummyTeamStores.indexWhere((s) => s.id == 'store-4');
    if (s4Idx != -1) {
      dummyTeamStores[s4Idx] = dummyTeamStores[s4Idx].copyWith(status: 'pending');
    }
    final s1Idx = dummyTeamStores.indexWhere((s) => s.id == 'store-1');
    if (s1Idx != -1) {
      dummyTeamStores[s1Idx] = dummyTeamStores[s1Idx].copyWith(isArchived: false);
    }
  });

  group('Phase 5B - Admin Store Functionality', () {
    testWidgets('Admin dashboard renders pending stores and campaign stores', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth));
      await tester.pumpAndSettle();

      expect(find.text('STORES & ORDERS'), findsOneWidget);
      expect(find.text('CAMPAIGN STORES'), findsOneWidget);

      expect(find.text('Pending School Store'), findsOneWidget);
      
      await tester.tap(find.text('CAMPAIGN STORES'));
      await tester.pumpAndSettle();
      
      expect(find.text('TCA Fall Campaign'), findsOneWidget);
    });

    testWidgets('Admin can approve a pending store', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth));
      await tester.pumpAndSettle();

      expect(find.text('APPROVE'), findsOneWidget);
      await tester.tap(find.text('APPROVE'));
      await tester.pumpAndSettle();

      final store = dummyTeamStores.firstWhere((s) => s.id == 'store-4');
      expect(store.status, 'approved');
    });

    testWidgets('Admin can create a campaign store', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGN STORES'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE CAMPAIGN STORE'));
      await tester.pumpAndSettle();

      final store = dummyTeamStores.last;
      expect(store.name, 'New Campaign Store');
      expect(store.status, 'approved');
      expect(store.userId, 'user-admin-1');
      expect(store.packageType, 'individual');
    });

    testWidgets('Admin Store Edit Screen renders components', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminStoreEditScreen(storeId: 'store-1'), auth));
      await tester.pumpAndSettle();

      expect(find.textContaining('Edit Store'), findsWidgets);
      expect(find.text('UPDATE COVER IMAGE'), findsOneWidget);
      expect(find.text('SAVE PRICING'), findsOneWidget);
      expect(find.text('Package Management'), findsOneWidget);
    });

    testWidgets('Admin can update bulk pricing', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminStoreEditScreen(storeId: 'store-1'), auth));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      await tester.enterText(textFields.first, '12.0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('SAVE PRICING'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('SAVE PRICING'));
      await tester.pumpAndSettle();

      expect(find.text('Store item pricing updated.'), findsOneWidget);
    });

    testWidgets('Admin can archive and unarchive a store', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminStoreEditScreen(storeId: 'store-1'), auth));
      await tester.pumpAndSettle();

      expect(find.text('ARCHIVE STORE'), findsOneWidget);
      await tester.tap(find.text('ARCHIVE STORE'));
      await tester.pumpAndSettle();
      
      expect(find.text('UNARCHIVE STORE'), findsOneWidget);

      await tester.tap(find.text('UNARCHIVE STORE'));
      await tester.pumpAndSettle();
      
      expect(find.text('ARCHIVE STORE'), findsOneWidget);
    });
  });
}





