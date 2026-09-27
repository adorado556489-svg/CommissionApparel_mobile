import 'dart:io';

void main() {
  var file = File('test/public_ui_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
'''Widget createTestApp(String initialRoute, {Object? arguments}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth())),
        Provider<FirebaseFirestore>.value(value: FakeFirebaseFirestore()),
      ],''', 
'''late FakeFirebaseFirestore globalFirestore;
Widget createTestApp(String initialRoute, {Object? arguments}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(firestore: globalFirestore, firebaseAuth: AutoSeedingMockFirebaseAuth())),
        Provider<FirebaseFirestore>.value(value: globalFirestore),
      ],''');
  
  content = content.replaceFirst("setUpAll(() {", "setUpAll(() async {\nglobalFirestore = FakeFirebaseFirestore();\nawait TestSeeder.seedAdminEnvironment(globalFirestore);\nawait TestSeeder.seedCoachStoreEnvironment(globalFirestore);");
  
  file.writeAsStringSync(content);
}
