import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:commission_apparel_flutter/app/app.dart';

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

  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(CommissionApparelApp(firestore: FakeFirebaseFirestore()));
    expect(find.text('Commission Apparel'), findsWidgets);
  });
}

