import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/theme.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/screens/user/open_store_request_screen.dart';
import 'helpers/test_seeder.dart';

void main() {
  for (final w in [360.0, 411.0]) {
    testWidgets('Open store request form has no layout overflow while typing @$w', (tester) async {
      tester.view.physicalSize = Size(w * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final fs = FakeFirebaseFirestore();
      await TestSeeder.seedAll(fs);
      final auth = AuthService(firestore: fs, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-parent-1', email: 'parent@test.com')));
      await auth.login('parent@test.com', 'password123');
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpWidget(MultiProvider(
        providers: [ChangeNotifierProvider.value(value: auth), Provider<FirebaseFirestore>.value(value: fs)],
        child: MaterialApp(theme: AppTheme.darkTheme, home: const OpenStoreRequestScreen()),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Hawks');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
