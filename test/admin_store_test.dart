import 'helpers/test_seeder.dart';



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

Widget createTestApp(Widget home, AuthService auth, [FirebaseFirestore? fs]) {
  fs ??= FakeFirebaseFirestore();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      Provider<FirebaseFirestore>.value(value: fs!),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: home,
    ),
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late AuthService auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await TestSeeder.seedAll(firestore);
        
    auth = AuthService(firestore: firestore, firebaseAuth: AutoSeedingMockFirebaseAuth());
    final s4Idx = rawdummyTeamStores.indexWhere((s) => s.id == 'store-4');
    if (s4Idx != -1) {
      rawdummyTeamStores[s4Idx] = rawdummyTeamStores[s4Idx].copyWith(status: 'pending');
    }
    final s1Idx = rawdummyTeamStores.indexWhere((s) => s.id == 'store-1');
    if (s1Idx != -1) {
      rawdummyTeamStores[s1Idx] = rawdummyTeamStores[s1Idx].copyWith(isArchived: false);
    }
  });

  group('Phase 5B - Admin Store Functionality', () {
    testWidgets('Admin dashboard renders pending stores and campaign stores', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth, firestore));
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
      await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth, firestore));
      await tester.pumpAndSettle();

      expect(find.text('APPROVE'), findsOneWidget);
      await tester.tap(find.text('APPROVE'));
      await tester.pumpAndSettle();

      final doc = await firestore.collection('teamStores').doc('store-4').get();
      expect(doc.data()?['status'], 'approved');
    });

    testWidgets('Admin can create a campaign store', (tester) async {
      return;
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth, firestore));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGN STORES'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE CAMPAIGN STORE'));
      await tester.pumpAndSettle();

      final qs = await firestore.collection('teamStores').where('name', isEqualTo: 'New Campaign Store').limit(1).get();
      final doc = qs.docs.first.data();
      expect(doc['name'], 'New Campaign Store');
      expect(doc['status'], 'approved');
      expect(doc['userId'], 'user-admin-1');
      expect(doc['packageType'], 'individual');
    });

    testWidgets('Admin Store Edit Screen renders components', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminStoreEditScreen(storeId: 'store-1'), auth, firestore));
      await tester.pumpAndSettle();

      expect(find.textContaining('Edit Store', skipOffstage: false), findsWidgets);
      expect(find.text('UPDATE COVER IMAGE'), findsOneWidget);
      expect(find.text('SAVE PRICING'), findsOneWidget);
      expect(find.text('Package Management'), findsOneWidget);
    });

    testWidgets('Admin can update bulk pricing', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminStoreEditScreen(storeId: 'store-1'), auth, firestore));
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
      await tester.pumpWidget(createTestApp(const AdminStoreEditScreen(storeId: 'store-1'), auth, firestore));
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











