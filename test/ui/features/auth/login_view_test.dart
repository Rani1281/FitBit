import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:fitbit/ui/core/widgets/custom_text_field.dart';
import 'package:fitbit/ui/core/widgets/inline_feedback_banner.dart';
import 'package:fitbit/ui/core/widgets/social_auth_button.dart';
import 'package:fitbit/ui/features/auth/view_models/auth_view_model.dart';
import 'package:fitbit/ui/features/auth/views/forgot_password_view.dart';
import 'package:fitbit/ui/features/auth/views/login_view.dart';
import 'package:fitbit/ui/features/auth/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/mock_auth_service.dart';

void main() {
  group('LoginView Widget Tests', () {
    late MockAuthService mockService;
    late AuthRepository repository;
    late AuthViewModel viewModel;

    setUp(() {
      mockService = MockAuthService();
      repository = AuthRepository(authService: mockService);
      viewModel = AuthViewModel(authRepository: repository);
    });

    tearDown(() {
      viewModel.dispose();
      mockService.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(home: LoginView(viewModel: viewModel));
    }

    testWidgets('renders all essential elements of the Login view', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Log into your account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('validates empty inputs on submit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('displays error banner when authentication fails', (
      WidgetTester tester,
    ) async {
      mockService.shouldFail = true;
      mockService.failureMessage = 'Invalid email or password.';

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(CustomTextField);
      await tester.enterText(textFields.at(0), 'runner@fitbit.com');
      await tester.enterText(textFields.at(1), 'wrong_pass');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.byType(InlineFeedbackBanner), findsOneWidget);
      expect(find.text('Invalid email or password.'), findsOneWidget);
    });

    testWidgets('switching between tabs clears errors on page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Trigger error in viewModel
      viewModel.setErrorMessage('Sample test error');
      await tester.pumpAndSettle();
      expect(find.text('Sample test error'), findsOneWidget);

      // Switch to Phone tab
      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();

      expect(viewModel.errorMessage, isNull);
      expect(find.text('Sample test error'), findsNothing);

      // Switch back to Email tab
      viewModel.setErrorMessage('Another error');
      await tester.pumpAndSettle();
      expect(find.text('Another error'), findsOneWidget);

      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();

      expect(viewModel.errorMessage, isNull);
      expect(find.text('Another error'), findsNothing);
    });

    testWidgets('navigating to register clears errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Trigger error
      viewModel.setErrorMessage('Sample test error');
      await tester.pumpAndSettle();
      expect(viewModel.errorMessage, isNotNull);

      // Tap Sign Up
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterView), findsOneWidget);
      expect(viewModel.errorMessage, isNull);
    });

    testWidgets('enters credentials and signs in successfully with email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(CustomTextField);
      await tester.enterText(textFields.at(0), 'runner@fitbit.com');
      await tester.enterText(textFields.at(1), 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(mockService.signInEmailCalls, equals(1));
      expect(viewModel.currentUser?.email, equals('runner@fitbit.com'));
    });

    testWidgets('switches to Phone tab and validates short phone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();

      final phoneField = find.byType(CustomTextField);
      await tester.enterText(phoneField, '+1234'); // Too short

      await tester.ensureVisible(find.text('Send Verification Code'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Phone number is too short'), findsOneWidget);
      expect(mockService.verifyPhoneNumberCalls, equals(0));
    });

    testWidgets(
      'switches to Phone tab and initiates phone verification with valid phone',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Phone'));
        await tester.pumpAndSettle();

        expect(find.text('Phone Number (International)'), findsOneWidget);
        expect(find.text('Send Verification Code'), findsOneWidget);

        final phoneField = find.byType(CustomTextField);
        await tester.enterText(phoneField, '+14155552671');

        await tester.ensureVisible(find.text('Send Verification Code'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Send Verification Code'));
        await tester.pumpAndSettle();

        expect(mockService.verifyPhoneNumberCalls, equals(1));
      },
    );

    testWidgets('triggers Google sign-in when button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(SocialAuthButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SocialAuthButton));
      await tester.pumpAndSettle();

      expect(mockService.signInWithGoogleCalls, equals(1));
      expect(viewModel.currentUser?.displayName, equals('Google Runner'));
    });

    testWidgets('navigates to ForgotPasswordView when link is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordView), findsOneWidget);
      expect(find.text('Reset Password'), findsOneWidget);
    });
  });
}
