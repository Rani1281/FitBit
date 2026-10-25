import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:fitbit/ui/core/widgets/custom_text_field.dart';
import 'package:fitbit/ui/features/auth/view_models/auth_view_model.dart';
import 'package:fitbit/ui/features/auth/views/forgot_password_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/mock_auth_service.dart';

void main() {
  group('ForgotPasswordView Widget Tests', () {
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
      return MaterialApp(home: ForgotPasswordView(viewModel: viewModel));
    }

    testWidgets('renders reset password form', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Send Reset Instructions'), findsOneWidget);
    });

    testWidgets('validates empty email field and sets error in viewModel', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Reset Instructions'));
      await tester.pumpAndSettle();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(
        viewModel.errorMessage,
        equals('Please enter a valid email address.'),
      );
    });

    testWidgets('sets error in viewModel when password reset fails', (
      WidgetTester tester,
    ) async {
      mockService.shouldFail = true;
      mockService.failureMessage = 'No account was found with this email.';

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(CustomTextField),
        'unknown@fitbit.com',
      );
      await tester.tap(find.text('Send Reset Instructions'));
      await tester.pumpAndSettle();

      expect(
        viewModel.errorMessage,
        equals('No account was found with this email.'),
      );
    });

    testWidgets('submits email and transitions to success view', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(CustomTextField),
        'forgotten@fitbit.com',
      );
      await tester.tap(find.text('Send Reset Instructions'));
      await tester.pumpAndSettle();

      expect(mockService.sendPasswordResetEmailCalls, equals(1));
      expect(find.text('Email Sent!'), findsOneWidget);
      expect(find.textContaining('forgotten@fitbit.com'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });
  });
}
