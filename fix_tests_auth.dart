import 'dart:io';

void main() {
  // 1. widget_test.dart
  var path = 'test/widget_test.dart';
  if (File(path).existsSync()) {
    var content = File(path).readAsStringSync();
    
    // widget_test.dart just checks if the app boots up and redirects to login!
    // Since AppRoutes.home redirects to LoginScreen when unauthenticated.
    content = content.replaceAll(
      "expect(find.textContaining('CUSTOM TEAM APPAREL'), findsWidgets);",
      "expect(find.textContaining('Sign in to your account'), findsWidgets);"
    );
    // Remove the multiple pumps we added earlier if they get in the way, but they're harmless.
    File(path).writeAsStringSync(content);
  }

  // 2. public_ui_test.dart
  path = 'test/public_ui_test.dart';
  if (File(path).existsSync()) {
    var content = File(path).readAsStringSync();
    
    // We need to inject an authenticated AuthService into createTestApp.
    // Replace createTestApp signature:
    content = content.replaceFirst(
      'Widget createTestApp(dynamic firestore, String initialRoute, {Object? arguments}) {',
      '''import 'helpers/auto_seeding_mock_auth.dart';
Widget createTestApp(dynamic firestore, String initialRoute, {Object? arguments, AuthService? authService}) {'''
    );
    
    // Replace the provider in createTestApp:
    content = content.replaceFirst(
      'ChangeNotifierProvider(create: (_) => AuthService(firestore: firestore)),',
      'ChangeNotifierProvider.value(value: authService ?? AuthService(firestore: firestore)),'
    );
    
    // Now replace tester.pumpWidget(createTestApp(...)) with an authenticated version:
    // First, let's just create an auth service at the top of the group.
    content = content.replaceFirst(
      "group('Phase 4 — Public UI Tests', () {",
      """group('Phase 4 — Public UI Tests', () {
    late AuthService auth;
    setUp(() async {
      auth = AuthService(firestore: firestore, firebaseAuth: AutoSeedingMockFirebaseAuth());
      await auth.login('parent@test.com', 'password123');
    });"""
    );
    
    // Replace all createTestApp(firestore, route... with createTestApp(firestore, route, authService: auth
    // Note: arguments are passed like `arguments: 'cat-1'`
    content = content.replaceAll(
      'createTestApp(firestore, AppRoutes.catalogCollection, arguments: \'cat-1\')',
      'createTestApp(firestore, AppRoutes.catalogCollection, arguments: \'cat-1\', authService: auth)'
    );
    content = content.replaceAll(
      'createTestApp(firestore, AppRoutes.catalog)',
      'createTestApp(firestore, AppRoutes.catalog, authService: auth)'
    );
    content = content.replaceAll(
      'createTestApp(firestore, AppRoutes.quote)',
      'createTestApp(firestore, AppRoutes.quote, authService: auth)'
    );
    content = content.replaceAll(
      'createTestApp(firestore, AppRoutes.storeDetail, arguments: \'store-1\')',
      'createTestApp(firestore, AppRoutes.storeDetail, arguments: \'store-1\', authService: auth)'
    );

    File(path).writeAsStringSync(content);
  }

  print('Done fixing auth in tests');
}
