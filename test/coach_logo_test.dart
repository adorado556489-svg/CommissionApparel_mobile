import 'helpers/test_seeder.dart';

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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'fixtures/dummy_users.dart';
import 'fixtures/dummy_stores.dart';
import 'fixtures/dummy_orders.dart';
import 'fixtures/dummy_catalog.dart';
import 'fixtures/dummy_content.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/src/pigeon/test_api.dart';
import 'package:firebase_core_platform_interface/src/pigeon/messages.pigeon.dart';

class MockFirebaseCoreHostApi implements TestFirebaseCoreHostApi {
  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return [
      CoreInitializeResponse(
        name: '[DEFAULT]',
        options: CoreFirebaseOptions(
          apiKey: '123',
          appId: '123',
          messagingSenderId: '123',
          projectId: '123',
        ),
        pluginConstants: {},
      )
    ];
  }

  @override
  Future<CoreInitializeResponse> initializeApp(String appName, CoreFirebaseOptions initializeAppRequest) async {
    return CoreInitializeResponse(
      name: appName,
      options: initializeAppRequest,
      pluginConstants: {},
    );
  }

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async {
    return CoreFirebaseOptions(
      apiKey: '123',
      appId: '123',
      messagingSenderId: '123',
      projectId: '123',
    );
  }
}

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestFirebaseCoreHostApi.setUp(MockFirebaseCoreHostApi());
}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('Phase I - Coach Logo Rendering Tests', () {
    late FakeFirebaseFirestore firestore;
    
    setUp(() async {
      firestore = FakeFirebaseFirestore();
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

    testWidgets('StoreDetailScreen renders store name and coach name when logoPath is null', (WidgetTester tester) async {
      await firestore.collection('users').doc('coach-1').set(
        User(password: '', updatedAt: DateTime.now(),id: 'coach-1', email: 'test@test.com', firstName: 'A', lastName: 'B', role: UserRole.coach, createdAt: DateTime.now()).toFirestore()
      );
      await firestore.collection('teamStores').doc('store-1').set(
        TeamStore(id: 'store-1', userId: 'coach-1', name: 'StoreNameWithoutLogo', slug: 's', createdAt: DateTime.now(), updatedAt: DateTime.now(), status: 'approved', pricingApproved: true).toFirestore()
      );

      await tester.pumpWidget(createTestApp(const StoreDetailScreen(storeId: 'store-1')));
      await tester.pumpAndSettle();

      expect(find.text('StoreNameWithoutLogo'), findsWidgets);
      expect(find.text('Coach: A B'), findsOneWidget);
    });

    testWidgets('StoreDetailScreen renders store name and coach name when logoPath is provided', (WidgetTester tester) async {
      await firestore.collection('users').doc('coach-2').set(
        User(password: '', updatedAt: DateTime.now(),id: 'coach-2', email: 'test2@test.com', firstName: 'A', lastName: 'B', role: UserRole.coach, logoPath: 'test_logo.png', createdAt: DateTime.now()).toFirestore()
      );
      await firestore.collection('teamStores').doc('store-2').set(
        TeamStore(id: 'store-2', userId: 'coach-2', name: 'StoreNameWithLogo', slug: 's', createdAt: DateTime.now(), updatedAt: DateTime.now(), status: 'approved', pricingApproved: true).toFirestore()
      );

      await tester.pumpWidget(createTestApp(const StoreDetailScreen(storeId: 'store-2')));
      await tester.pumpAndSettle();

      expect(find.text('StoreNameWithLogo'), findsWidgets);
      expect(find.text('Coach: A B'), findsOneWidget);
    });
  });
}
