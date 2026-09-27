import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/screens/public/store_search_screen.dart';
import 'package:commission_apparel_flutter/screens/public/store_detail_screen.dart';
import 'helpers/test_seeder.dart';
import 'fixtures/dummy_users.dart';
import 'fixtures/dummy_stores.dart';
import 'fixtures/dummy_orders.dart';
import 'fixtures/dummy_catalog.dart';
import 'fixtures/dummy_content.dart';
import 'fixtures/dummy_quotes.dart';

void main() {
  TestSeeder.populateDummyFallbacks();

  group('Phase I - Coach Logo Rendering Tests', () {
    late FakeFirebaseFirestore firestore;
    
    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAdminEnvironment(firestore);
    await TestSeeder.seedAll(firestore);
    });

    Widget createTestApp(Widget child) {
      return MultiProvider(
        providers: [
          Provider<FirebaseFirestore>.value(value: firestore),
          ChangeNotifierProvider<AuthService>(create: (_) => AuthService(firestore: firestore)),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('StoreDetailScreen renders placeholder icon when logoPath is null', (WidgetTester tester) async {
      await firestore.collection('users').doc('coach-1').set(
        User(password: '', updatedAt: DateTime.now(),id: 'coach-1', email: 'test@test.com', firstName: 'A', lastName: 'B', role: UserRole.coach, createdAt: DateTime.now()).toFirestore()
      );
      await firestore.collection('teamStores').doc('store-1').set(
        TeamStore(id: 'store-1', userId: 'coach-1', name: 'S', slug: 's', createdAt: DateTime.now(), updatedAt: DateTime.now(), status: 'approved', pricingApproved: true).toFirestore()
      );

      await tester.pumpWidget(createTestApp(const StoreDetailScreen(storeId: 'store-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('StoreDetailScreen renders logo image when logoPath is provided', (WidgetTester tester) async {
      await firestore.collection('users').doc('coach-2').set(
        User(password: '', updatedAt: DateTime.now(),id: 'coach-2', email: 'test2@test.com', firstName: 'A', lastName: 'B', role: UserRole.coach, logoPath: 'test_logo.png', createdAt: DateTime.now()).toFirestore()
      );
      await firestore.collection('teamStores').doc('store-2').set(
        TeamStore(id: 'store-2', userId: 'coach-2', name: 'S', slug: 's', createdAt: DateTime.now(), updatedAt: DateTime.now(), status: 'approved', pricingApproved: true).toFirestore()
      );

      await tester.pumpWidget(createTestApp(const StoreDetailScreen(storeId: 'store-2')));
      await tester.pumpAndSettle();

      // Expect no shield icon because logo is present
      expect(find.byIcon(Icons.shield), findsNothing);
    });
  });
}
