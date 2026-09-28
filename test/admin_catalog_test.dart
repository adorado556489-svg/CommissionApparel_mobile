import 'helpers/test_seeder.dart';



import 'helpers/auto_seeding_mock_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/theme.dart';



import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/screens/admin/admin_dashboard_screen.dart';


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
        
    auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
  });

  group('Phase 5C - Admin Catalog Functionality', () {
    testWidgets('Admin can create a collection', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text('COLLECTIONS')));
      await tester.pumpAndSettle();

      // Create
      await tester.tap(find.text('CREATE NEW COLLECTION'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test Collection X');
      await tester.ensureVisible(find.text('SAVE COLLECTION'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SAVE COLLECTION'));
      await tester.pump(); // wait for snackbar
      
      expect(find.text('Collection "Test Collection X" created.'), findsOneWidget);
    });
    
    testWidgets('Admin can create a design', (tester) async {
      await auth.login('admin@commissionapparel.com', 'password123');
      await tester.pumpWidget(createTestApp(const AdminDashboardScreen(), auth));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text('CATALOG')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE NEW DESIGN'));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.widgetWithText(TextFormField, 'Design Name'), 'Test Cascade Design');
      await tester.enterText(find.widgetWithText(TextFormField, 'Wholesale Price (\$)'), '30.0');
      
      // Select type
      await tester.ensureVisible(find.widgetWithText(FilterChip, 'Shorts'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Shorts'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('SAVE DESIGN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SAVE DESIGN'));
      await tester.pump();
      expect(find.text('Design "Test Cascade Design" created.'), findsOneWidget);
    });
  });
}





