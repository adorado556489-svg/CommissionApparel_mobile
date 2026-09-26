
import 'helpers/auto_seeding_mock_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/app/routes.dart';
import 'package:commission_apparel_flutter/app/theme.dart';

Widget createTestApp(String initialRoute, {Object? arguments}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth())),
      Provider<FirebaseFirestore>.value(value: FakeFirebaseFirestore()),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        if (settings.name == initialRoute) {
          return AppRoutes.onGenerateRoute(RouteSettings(name: initialRoute, arguments: arguments));
        }
        return AppRoutes.onGenerateRoute(settings);
      },
    ),
  );
}

void main() {
  setUpAll(() {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('AssetImage') ||
          details.exceptionAsString().contains('Unable to load asset')) {
        return;
      }
      originalOnError?.call(details);
    };
  });

  group('Phase 4 — Public UI Tests', () {
    testWidgets('HomeScreen renders hero and collections', (tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.home));
      await tester.pumpAndSettle();
      
      expect(find.text('CUSTOM TEAM APPAREL MADE EASY'), findsOneWidget); // Hero Title
      expect(find.text('VIEW OUR CUSTOM COLLECTIONS'), findsOneWidget);
      expect(find.text('WHY CHOOSE US?'), findsOneWidget);
    });

    testWidgets('CatalogScreen renders filter and collections', (tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.catalog));
      await tester.pumpAndSettle();
      
      expect(find.text('VIEW FULL CATALOG'), findsOneWidget);
      expect(find.text('FILTER BY CATEGORIES'), findsOneWidget);
      expect(find.text('Basketball Collection'), findsWidgets);
    });

    testWidgets('CatalogCollectionScreen renders designs', (tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.catalogCollection, arguments: 'col-basketball'));
      await tester.pumpAndSettle();
      
      expect(find.text('Basketball Game Package'), findsWidgets);
      expect(find.text('Basketball Jersey'), findsWidgets);
    });

    testWidgets('StoreSearchScreen renders stores', (tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.storeSearch));
      await tester.pumpAndSettle();
      
      expect(find.text('TEAM STORES'), findsWidgets);
      expect(find.text('SEARCH'), findsWidgets);
      // store-1 should be visible
      expect(find.text('Riverside Academy Basketball'), findsWidgets);
    });

    testWidgets('StoreDetailScreen renders store items', (tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.storeDetail, arguments: 'store-1'));
      await tester.pumpAndSettle();
      
      expect(find.text('RIVERSIDE ACADEMY BASKETBALL'), findsWidgets);
      expect(find.text('ORDER DEADLINE'), findsWidgets);
      expect(find.text('Game Day Package'), findsWidgets);
    });

    testWidgets('QuoteScreen renders form and validates required fields', (tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.quote));
      await tester.pumpAndSettle();
      
      expect(find.text('BUILD YOUR ARMOR'), findsWidgets);
      expect(find.text('1. Point of Contact'), findsWidgets);
      
      // Tap submit without filling
      final submitButton = find.text('SUBMIT QUOTE REQUEST');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      // Validation error should appear
      expect(find.text('This field is required'), findsWidgets);
    });
  });
}




