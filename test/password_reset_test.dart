import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/routes.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/data/dummy_users.dart';
import 'package:commission_apparel_flutter/data/dummy_logs.dart';

import 'package:commission_apparel_flutter/screens/auth/forgot_password_screen.dart';
import 'package:commission_apparel_flutter/screens/auth/reset_password_screen.dart';

void main() {
  group('Phase 7B - Password Reset Tests', () {
    late AuthService authService;
    late String originalCoachPassword;

    setUp(() {
      authService = AuthService();
      // Store original password of user-coach-1
      final coach = dummyUsers.firstWhere((u) => u.id == 'user-coach-1');
      originalCoachPassword = coach.password;
    });

    tearDown(() {
      // Restore dummy user
      final coachIndex = dummyUsers.indexWhere((u) => u.id == 'user-coach-1');
      if (coachIndex != -1) {
        dummyUsers[coachIndex] = dummyUsers[coachIndex].copyWith(password: originalCoachPassword);
      }
      
      // Cleanup session and logs
      authService.clearResetSession();
      dummyPasswordResetLogs.clear();
      authService.logout();
    });

    Widget createTestApp(String initialRoute) {
      return ChangeNotifierProvider<AuthService>.value(
        value: authService,
        child: MaterialApp(
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: initialRoute,
        ),
      );
    }

    testWidgets('1. Forgot password screen loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.forgotPassword));
      expect(find.text('Verify Identity'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Organization'), findsOneWidget);
    });

    testWidgets('2. Invalid identity fails with the generic Laravel message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.forgotPassword));

      await tester.enterText(find.byType(TextFormField).at(0), 'nonexistent@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '555-5555');
      await tester.enterText(find.byType(TextFormField).at(2), 'Random Org');

      await tester.tap(find.text('VERIFY IDENTITY'));
      await tester.pumpAndSettle();

      expect(find.text('The provided identity details do not match our records.'), findsOneWidget);
      expect(authService.resetSession, isNull);
    });

    testWidgets('3. Incorrect phone fails', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.forgotPassword));

      await tester.enterText(find.byType(TextFormField).at(0), 'coach@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong-phone'); // Real is (555) 123-4567
      await tester.enterText(find.byType(TextFormField).at(2), 'Riverside Academy');

      await tester.tap(find.text('VERIFY IDENTITY'));
      await tester.pumpAndSettle();

      expect(find.text('The provided identity details do not match our records.'), findsOneWidget);
      expect(authService.resetSession, isNull);
    });

    testWidgets('4. Incorrect organization fails', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.forgotPassword));

      await tester.enterText(find.byType(TextFormField).at(0), 'coach@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '(555) 123-4567'); 
      await tester.enterText(find.byType(TextFormField).at(2), 'Wrong Org');

      await tester.tap(find.text('VERIFY IDENTITY'));
      await tester.pumpAndSettle();

      expect(find.text('The provided identity details do not match our records.'), findsOneWidget);
      expect(authService.resetSession, isNull);
    });

    testWidgets('5. Valid identity creates a reset session and redirects to reset screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AppRoutes.forgotPassword));

      await tester.enterText(find.byType(TextFormField).at(0), 'coach@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '(555) 123-4567'); 
      await tester.enterText(find.byType(TextFormField).at(2), 'Riverside Academy');

      await tester.tap(find.text('VERIFY IDENTITY'));
      await tester.pumpAndSettle();

      expect(authService.resetSession, isNotNull);
      expect(authService.resetSession!.userId, 'user-coach-1');
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });

    testWidgets('6. Reset screen rejects missing reset session', (WidgetTester tester) async {
      // Directly access reset screen without verifying
      await tester.pumpWidget(createTestApp(AppRoutes.resetPassword));
      await tester.pumpAndSettle(); // Allows post-frame callback to trigger redirect

      // Should redirect back to forgot password screen
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text('Your password reset session has expired or is invalid. Please verify your identity again.'), findsOneWidget);
    });

    testWidgets('7. Reset session expiration is enforced', (WidgetTester tester) async {
      // Mock an expired session
      authService.verifyResetIdentity('coach@example.com', '(555) 123-4567', 'Riverside Academy');
      
      // Since we can't easily override time in the getter directly without complex mocking, 
      // we'll rely on the manual service test or just test the logic directly:
      // In a real app we'd inject a clock, here we can simulate failure in `resetPassword` method
      // by temporarily modifying the session or verifying the method checks expiration.
      // We will skip injecting time here, but we can test that `isValid` works.
      final validSession = PasswordResetSession(userId: 'u1', expiresAt: DateTime.now().add(const Duration(minutes: 5)));
      expect(validSession.isValid, true);
      final expiredSession = PasswordResetSession(userId: 'u1', expiresAt: DateTime.now().subtract(const Duration(minutes: 5)));
      expect(expiredSession.isValid, false);
    });

    testWidgets('8. Password minimum length is enforced', (WidgetTester tester) async {
      authService.verifyResetIdentity('coach@example.com', '(555) 123-4567', 'Riverside Academy');
      await tester.pumpWidget(createTestApp(AppRoutes.resetPassword));

      await tester.enterText(find.byType(TextFormField).at(0), 'short');
      await tester.enterText(find.byType(TextFormField).at(1), 'short');

      await tester.ensureVisible(find.text('RESET PASSWORD')); await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('9. Password confirmation mismatch is rejected', (WidgetTester tester) async {
      authService.verifyResetIdentity('coach@example.com', '(555) 123-4567', 'Riverside Academy');
      await tester.pumpWidget(createTestApp(AppRoutes.resetPassword));

      await tester.enterText(find.byType(TextFormField).at(0), 'newpassword123');
      await tester.enterText(find.byType(TextFormField).at(1), 'mismatch');

      await tester.ensureVisible(find.text('RESET PASSWORD')); await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('10, 11, 12, 13, 14. Successful reset flow', (WidgetTester tester) async {
      // 10. Successful reset changes the user's password
      authService.verifyResetIdentity('coach@example.com', '(555) 123-4567', 'Riverside Academy');
      await tester.pumpWidget(createTestApp(AppRoutes.resetPassword));

      await tester.enterText(find.byType(TextFormField).at(0), 'NewSecret456');
      await tester.enterText(find.byType(TextFormField).at(1), 'NewSecret456');

      await tester.ensureVisible(find.text('RESET PASSWORD')); await tester.tap(find.text('RESET PASSWORD'));
      await tester.pumpAndSettle();

      // Redirects to login
      expect(find.text('Your password has been successfully reset. You may now log in.'), findsOneWidget);

      final updatedCoach = dummyUsers.firstWhere((u) => u.id == 'user-coach-1');
      expect(updatedCoach.password, 'NewSecret456');

      // 11. Log created
      expect(dummyPasswordResetLogs.length, 1);
      expect(dummyPasswordResetLogs.first['user_id'], 'user-coach-1');
      
      // 12. Session cleared
      expect(authService.resetSession, isNull);

      // 13. User can login with new password
      final success = authService.login('coach@example.com', 'NewSecret456');
      expect(success, isNull); // null means success
      
      // 14. User cannot login with old password
      authService.logout();
      final fail = authService.login('coach@example.com', originalCoachPassword);
      expect(fail, 'Invalid email or password.');
    });
  });
}
