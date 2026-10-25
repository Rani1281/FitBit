import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:fitbit/domain/models/user_entity.dart';
import 'package:fitbit/ui/core/widgets/inline_feedback_banner.dart';
import 'package:fitbit/ui/features/auth/view_models/auth_view_model.dart';
import 'package:fitbit/ui/features/auth/views/email_verification_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/mock_auth_service.dart';

void main() {
  group('EmailVerificationView Widget Tests', () {
    late MockAuthService mockService;
    late AuthRepository repository;
    late AuthViewModel viewModel;

    setUp(() {
      const user = UserEntity(
        id: 'user_email_unverified',
        email: 'verify.me@fitbit.com',
        displayName: 'Unverified Athlete',
        isEmailVerified: false,
        providerType: AuthProviderType.email,
      );
      mockService = MockAuthService(initialUser: user);
      repository = AuthRepository(authService: mockService);
      viewModel = AuthViewModel(authRepository: repository);
    });

    tearDown(() {
      viewModel.dispose();
      mockService.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(home: EmailVerificationView(viewModel: viewModel));
    }

    testWidgets(
      'renders email verification UI, user email, and auto-checking status',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Verify Your Email'), findsOneWidget);
        expect(
          find.textContaining('verify.me@fitbit.com', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.text('Checking verification status automatically...'),
          findsOneWidget,
        );
        expect(find.text('I Have Verified My Email'), findsNothing);
        expect(find.text('Resend Verification Email'), findsOneWidget);
        expect(find.text('Continue to Dashboard anyway'), findsOneWidget);
        expect(find.text('Sign Out'), findsOneWidget);
      },
    );

    testWidgets('automatically checks verification status periodically', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(mockService.reloadUserCalls, equals(0));

      // Advance by 3 seconds for first check
      await tester.pump(const Duration(seconds: 3));
      expect(mockService.reloadUserCalls, equals(1));
    });

    testWidgets(
      'tapping resend triggers sendEmailVerification and starts countdown',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.tap(find.text('Resend Verification Email'));
        await tester.pump();

        expect(mockService.sendEmailVerificationCalls, equals(1));
        expect(find.textContaining('Resend email in'), findsOneWidget);
      },
    );

    testWidgets('shows error feedback when resend verification fails', (
      WidgetTester tester,
    ) async {
      mockService.shouldFail = true;
      mockService.failureMessage =
          'Too many attempts. Please wait a moment and try again.';

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Resend Verification Email'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(InlineFeedbackBanner), findsOneWidget);
      expect(
        find.text('Too many attempts. Please wait a moment and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('sign out button signs user out', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Sign Out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(mockService.signOutCalls, equals(1));
      expect(viewModel.currentUser, isNull);
    });
  });
}
