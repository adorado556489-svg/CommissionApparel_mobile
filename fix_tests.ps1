$uiTestPath = "c:\Users\User\Flutter Projects\commission_apparel_flutter\test\public_ui_test.dart"
$uiTest = Get-Content $uiTestPath -Raw
$uiTest = $uiTest -replace 'Widget createTestApp\(String initialRoute, \{Object\? arguments\}\) \{', 'Widget createTestApp(FirebaseFirestore firestore, String initialRoute, {Object? arguments}) {'
$uiTest = $uiTest -replace 'AuthService\(firestore: FakeFirebaseFirestore\(\)', 'AuthService(firestore: firestore'
$uiTest = $uiTest -replace 'Provider<FirebaseFirestore>\.value\(value: FakeFirebaseFirestore\(\)\)', 'Provider<FirebaseFirestore>.value(value: firestore)'
$uiTest = $uiTest -replace "group\('Phase 4 — Public UI Tests', \(\) \{", "late FakeFirebaseFirestore firestore;`n  setUp(() async {`n    firestore = FakeFirebaseFirestore();`n    await TestSeeder.seedAll(firestore);`n  });`n`n  group('Phase 4 — Public UI Tests', () {"
$uiTest = $uiTest -replace 'createTestApp\(AppRoutes\.home\)', 'createTestApp(firestore, AppRoutes.home)'
$uiTest = $uiTest -replace 'createTestApp\(AppRoutes\.catalog\)', 'createTestApp(firestore, AppRoutes.catalog)'
$uiTest = $uiTest -replace "createTestApp\('/catalog/collection', arguments: 'col-basketball'\)", "createTestApp(firestore, '/catalog/collection', arguments: 'col-basketball')"
$uiTest = $uiTest -replace 'createTestApp\(AppRoutes\.storeSearch\)', 'createTestApp(firestore, AppRoutes.storeSearch)'
$uiTest = $uiTest -replace "createTestApp\(AppRoutes\.storeDetail, arguments: 'store-1'\)", "createTestApp(firestore, AppRoutes.storeDetail, arguments: 'store-1')"
$uiTest = $uiTest -replace 'createTestApp\(AppRoutes\.quote\)', 'createTestApp(firestore, AppRoutes.quote)'
$uiTest = $uiTest -replace "find\.text\('VIEW OUR CUSTOM COLLECTIONS'\)", "find.text('Featured Collections')"
$uiTest = $uiTest -replace "find\.text\('WHY CHOOSE US\?'\)", "find.text('What Coaches Say')"
Set-Content $uiTestPath $uiTest

$widgetTestPath = "c:\Users\User\Flutter Projects\commission_apparel_flutter\test\widget_test.dart"
$widgetTest = Get-Content $widgetTestPath -Raw
$widgetTest = $widgetTest -replace "testWidgets\('App renders home screen'", "late FakeFirebaseFirestore firestore;`n  setUp(() async {`n    firestore = FakeFirebaseFirestore();`n    await TestSeeder.seedAll(firestore);`n  });`n`n  testWidgets('App renders home screen'"
$widgetTest = $widgetTest -replace 'CommissionApparelApp\(firestore: FakeFirebaseFirestore\(\)\)', 'CommissionApparelApp(firestore: firestore)'
$widgetTest = $widgetTest -replace "find\.text\('Commission Apparel'\)", "find.text('CUSTOM TEAM APPAREL MADE EASY')"
Set-Content $widgetTestPath $widgetTest

$routeGuardTestPath = "c:\Users\User\Flutter Projects\commission_apparel_flutter\test\route_guard_test.dart"
$routeGuardTest = Get-Content $routeGuardTestPath -Raw
$routeGuardTest = $routeGuardTest -replace 'Widget createTestApp\(AuthService authService, String initialRoute\) \{', 'Widget createTestApp(FirebaseFirestore firestore, AuthService authService, String initialRoute) {'
$routeGuardTest = $routeGuardTest -replace 'Provider<FirebaseFirestore>\.value\(value: FakeFirebaseFirestore\(\)\)', 'Provider<FirebaseFirestore>.value(value: firestore)'
$routeGuardTest = $routeGuardTest -replace "group\('Phase 3 — Route Guard & Navigation Tests', \(\) \{", "late FakeFirebaseFirestore firestore;`n  setUp(() async {`n    firestore = FakeFirebaseFirestore();`n    await TestSeeder.seedAll(firestore);`n  });`n`n  group('Phase 3 — Route Guard & Navigation Tests', () {"
$routeGuardTest = $routeGuardTest -replace 'AuthService\(firestore: FakeFirebaseFirestore\(\)', 'AuthService(firestore: firestore'
$routeGuardTest = $routeGuardTest -replace 'createTestApp\(auth, ', 'createTestApp(firestore, auth, '
Set-Content $routeGuardTestPath $routeGuardTest
