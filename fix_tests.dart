import 'dart:io';

void main() {
  final uiTestPath = 'test/public_ui_test.dart';
  var uiTest = File(uiTestPath).readAsStringSync();
  
  uiTest = uiTest.replaceAll('Widget createTestApp(String initialRoute, {Object? arguments}) {', 'Widget createTestApp(dynamic firestore, String initialRoute, {Object? arguments}) {');
  uiTest = uiTest.replaceAll('AuthService(firestore: FakeFirebaseFirestore()', 'AuthService(firestore: firestore');
  uiTest = uiTest.replaceAll('Provider<FirebaseFirestore>.value(value: FakeFirebaseFirestore())', 'Provider<FirebaseFirestore>.value(value: firestore)');
  uiTest = uiTest.replaceAll('createTestApp(AppRoutes.home)', 'createTestApp(firestore, AppRoutes.home)');
  uiTest = uiTest.replaceAll('createTestApp(AppRoutes.catalog)', 'createTestApp(firestore, AppRoutes.catalog)');
  uiTest = uiTest.replaceAll("createTestApp('/catalog/collection', arguments: 'col-basketball')", "createTestApp(firestore, '/catalog/collection', arguments: 'col-basketball')");
  uiTest = uiTest.replaceAll('createTestApp(AppRoutes.storeSearch)', 'createTestApp(firestore, AppRoutes.storeSearch)');
  uiTest = uiTest.replaceAll("createTestApp(AppRoutes.storeDetail, arguments: 'store-1')", "createTestApp(firestore, AppRoutes.storeDetail, arguments: 'store-1')");
  uiTest = uiTest.replaceAll('createTestApp(AppRoutes.quote)', 'createTestApp(firestore, AppRoutes.quote)');
  uiTest = uiTest.replaceAll("find.text('VIEW OUR CUSTOM COLLECTIONS')", "find.text('Featured Collections')");
  uiTest = uiTest.replaceAll("find.text('WHY CHOOSE US?')", "find.text('What Coaches Say')");
  uiTest = uiTest.replaceAll("group('Phase 4 — Public UI Tests', () {", '''
  late FakeFirebaseFirestore firestore;
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await TestSeeder.seedAll(firestore);
  });

  group('Phase 4 — Public UI Tests', () {''');
  
  File(uiTestPath).writeAsStringSync(uiTest);

  final widgetTestPath = 'test/widget_test.dart';
  var widgetTest = File(widgetTestPath).readAsStringSync();
  widgetTest = widgetTest.replaceAll("testWidgets('App renders home screen'", '''
  late FakeFirebaseFirestore firestore;
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await TestSeeder.seedAll(firestore);
  });

  testWidgets('App renders home screen'
  ''');
  widgetTest = widgetTest.replaceAll('CommissionApparelApp(firestore: FakeFirebaseFirestore())', 'CommissionApparelApp(firestore: firestore)');
  widgetTest = widgetTest.replaceAll("find.text('Commission Apparel')", "find.text('CUSTOM TEAM APPAREL MADE EASY')");
  File(widgetTestPath).writeAsStringSync(widgetTest);

  final routeGuardTestPath = 'test/route_guard_test.dart';
  var routeGuardTest = File(routeGuardTestPath).readAsStringSync();
  routeGuardTest = routeGuardTest.replaceAll('Widget createTestApp(AuthService authService, String initialRoute) {', 'Widget createTestApp(dynamic firestore, AuthService authService, String initialRoute) {');
  routeGuardTest = routeGuardTest.replaceAll('Provider<FirebaseFirestore>.value(value: FakeFirebaseFirestore())', 'Provider<FirebaseFirestore>.value(value: firestore)');
  routeGuardTest = routeGuardTest.replaceAll("group('Phase 3 — Route Guard & Navigation Tests', () {", '''
  late FakeFirebaseFirestore firestore;
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await TestSeeder.seedAll(firestore);
  });

  group('Phase 3 — Route Guard & Navigation Tests', () {''');
  routeGuardTest = routeGuardTest.replaceAll('AuthService(firestore: FakeFirebaseFirestore()', 'AuthService(firestore: firestore');
  routeGuardTest = routeGuardTest.replaceAll('createTestApp(auth, ', 'createTestApp(firestore, auth, ');
  File(routeGuardTestPath).writeAsStringSync(routeGuardTest);
  print('Done applying test fixes!');
}
