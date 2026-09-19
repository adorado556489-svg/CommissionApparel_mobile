import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/theme.dart';
import 'package:commission_apparel_flutter/data/dummy_catalog.dart';
import 'package:commission_apparel_flutter/data/dummy_stores.dart';
import 'package:commission_apparel_flutter/data/dummy_users.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/screens/admin/admin_dashboard_screen.dart';
import 'package:commission_apparel_flutter/models/store_item.dart';

Widget createTestApp(Widget home, AuthService auth) {
  return ChangeNotifierProvider.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: home,
    ),
  );
}

void main() {
  late AuthService auth;

  setUp(() {
    auth = AuthService();
  });

  group('Phase 5C - Admin Catalog Functionality', () {
    testWidgets('Admin can create a collection', (tester) async {
      auth.login('admin@commissionapparel.com', 'password');
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
      auth.login('admin@commissionapparel.com', 'password');
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
