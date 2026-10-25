import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:fitbit/ui/core/widgets/custom_text_field.dart';
import 'package:fitbit/ui/core/widgets/inline_feedback_banner.dart';
import 'package:fitbit/ui/features/auth/view_models/auth_view_model.dart';
import 'package:fitbit/ui/features/auth/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/mock_auth_service.dart';

void main() {
  group('RegisterView Widget Tests', () {
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
      return MaterialApp(home: RegisterView(viewModel: viewModel));
    }

    testWidgets('renders all registration elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start your journey'), findsOneWidget);
      expect(find.text('Create a new account'), findsOneWidget);
      expect(find.text('Email'), findsNWidgets(2));
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign up with Google'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('validates required fields on register submit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('validates password confirmation match', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fields = find.byType(CustomTextField);
      await tester.enterText(fields.at(0), 'Morgan');
      await tester.enterText(fields.at(1), 'morgan@fitbit.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'different_password');

      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('displays error banner when registration fails', (
      WidgetTester tester,
    ) async {
      mockService.shouldFail = true;
      mockService.failureMessage =
          'An account already exists with this email address.';

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fields = find.byType(CustomTextField);
      await tester.enterText(fields.at(0), 'Morgan');
      await tester.enterText(fields.at(1), 'existing@fitbit.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.byType(InlineFeedbackBanner), findsOneWidget);
      expect(
        find.text('An account already exists with this email address.'),
        findsOneWidget,
      );
    });

    testWidgets('switching between tabs clears errors on register view', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Trigger error in viewModel
      viewModel.setErrorMessage('Sample register error');
      await tester.pumpAndSettle();
      expect(find.text('Sample register error'), findsOneWidget);

      // Switch to Phone tab
      await tester.ensureVisible(find.text('Phone'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();

      expect(viewModel.errorMessage, isNull);
      expect(find.text('Sample register error'), findsNothing);
    });

    testWidgets('submits valid registration and registers user', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fields = find.byType(CustomTextField);
      await tester.enterText(fields.at(0), 'Morgan');
      await tester.enterText(fields.at(1), 'morgan@fitbit.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(mockService.registerEmailCalls, equals(1));
      expect(viewModel.currentUser?.displayName, equals('Morgan'));
    });

    testWidgets('validates short phone number on phone register tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();

      final fields = find.byType(CustomTextField);
      await tester.enterText(fields.at(0), 'Casey');
      await tester.enterText(fields.at(1), '+1234'); // Too short

      await tester.ensureVisible(find.text('Send SMS Verification'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send SMS Verification'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Phone number is too short'), findsOneWidget);
      expect(mockService.verifyPhoneNumberCalls, equals(0));
    });

    testWidgets('switches to phone tab and sends SMS verification code', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();

      expect(find.text('Send SMS Verification'), findsOneWidget);

      final fields = find.byType(CustomTextField);
      await tester.enterText(fields.at(0), 'Casey');
      await tester.enterText(fields.at(1), '+14155558899');

      await tester.ensureVisible(find.text('Send SMS Verification'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send SMS Verification'));
      await tester.pumpAndSettle();

      expect(mockService.verifyPhoneNumberCalls, equals(1));
    });
  });
}
