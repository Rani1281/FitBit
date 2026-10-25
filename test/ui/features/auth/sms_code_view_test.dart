import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:fitbit/ui/core/widgets/custom_text_field.dart';
import 'package:fitbit/ui/core/widgets/inline_feedback_banner.dart';
import 'package:fitbit/ui/features/auth/view_models/auth_view_model.dart';
import 'package:fitbit/ui/features/auth/views/sms_code_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/mock_auth_service.dart';

void main() {
  group('SmsCodeView Widget Tests', () {
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
      return MaterialApp(
        home: SmsCodeView(viewModel: viewModel, phoneNumber: '+14155552671'),
      );
    }

    testWidgets('renders SMS verification screen with phone number', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('SMS Verification'), findsOneWidget);
      expect(find.textContaining('+14155552671'), findsOneWidget);
      expect(find.text('6-Digit Code'), findsOneWidget);
      expect(find.text('Verify & Sign In'), findsOneWidget);
      expect(find.textContaining('Resend code in'), findsOneWidget);
    });

    testWidgets('validates 6-digit requirement for SMS code and warns user', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Verify & Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Verification code is required'), findsOneWidget);
      expect(
        find.text('Please enter the full 6-digit code received via SMS.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(CustomTextField), '123');
      await tester.tap(find.text('Verify & Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter the full 6-digit code'), findsOneWidget);
    });

    testWidgets('displays error banner when SMS code is invalid', (
      WidgetTester tester,
    ) async {
      await viewModel.startPhoneAuth(
        phoneNumber: '+14155552671',
        onCodeSent: () {},
      );

      mockService.shouldFail = true;
      mockService.failureMessage =
          'The 6-digit SMS verification code entered is incorrect.';

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(CustomTextField), '000000');
      await tester.tap(find.text('Verify & Sign In'));
      await tester.pumpAndSettle();

      expect(find.byType(InlineFeedbackBanner), findsOneWidget);
      expect(
        find.text('The 6-digit SMS verification code entered is incorrect.'),
        findsOneWidget,
      );
    });

    testWidgets('submits 6-digit code and calls verifySmsCode', (
      WidgetTester tester,
    ) async {
      await viewModel.startPhoneAuth(
        phoneNumber: '+14155552671',
        onCodeSent: () {},
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(CustomTextField), '654321');
      await tester.tap(find.text('Verify & Sign In'));
      await tester.pumpAndSettle();

      expect(mockService.signInWithSmsCodeCalls, equals(1));
      expect(viewModel.currentUser?.phoneNumber, equals('+1234567890'));
    });
  });
}
