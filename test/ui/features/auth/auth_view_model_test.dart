import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:fitbit/ui/features/auth/view_models/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/mock_auth_service.dart';

void main() {
  group('AuthViewModel Unit Tests', () {
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

    test('initial state has null currentUser and false loading states', () {
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isEmailLoading, isFalse);
      expect(viewModel.isPhoneLoading, isFalse);
      expect(viewModel.isGoogleLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.successMessage, isNull);
    });

    test(
      'loginWithEmail sets loading and updates currentUser on success',
      () async {
        final success = await viewModel.loginWithEmail(
          email: 'alex@fitbit.com',
          password: 'password123',
        );

        expect(success, isTrue);
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.currentUser?.email, equals('alex@fitbit.com'));
        expect(viewModel.successMessage, contains('successfully'));
        expect(viewModel.isEmailLoading, isFalse);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
      },
    );

    test('loginWithEmail sets errorMessage when service throws', () async {
      mockService.shouldFail = true;
      mockService.failureMessage = 'Invalid credentials';

      final success = await viewModel.loginWithEmail(
        email: 'alex@fitbit.com',
        password: 'wrong',
      );

      expect(success, isFalse);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.errorMessage, equals('Invalid credentials'));
      expect(viewModel.isEmailLoading, isFalse);
    });

    test('registerWithEmail updates user and sets successMessage', () async {
      final success = await viewModel.registerWithEmail(
        email: 'newuser@fitbit.com',
        password: 'password123',
        firstName: 'Charlie',
      );

      expect(success, isTrue);
      expect(viewModel.currentUser?.displayName, equals('Charlie'));
      expect(viewModel.successMessage, contains('Account created'));
      expect(viewModel.isEmailLoading, isFalse);
    });

    test('sendEmailVerification handles success and failure', () async {
      var success = await viewModel.sendEmailVerification();
      expect(success, isTrue);
      expect(viewModel.successMessage, contains('Verification link sent'));

      mockService.shouldFail = true;
      success = await viewModel.sendEmailVerification();
      expect(success, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('sendPasswordResetEmail sets success or error accordingly', () async {
      var success = await viewModel.sendPasswordResetEmail(
        email: 'reset@fitbit.com',
      );
      expect(success, isTrue);
      expect(viewModel.successMessage, contains('reset@fitbit.com'));

      mockService.shouldFail = true;
      success = await viewModel.sendPasswordResetEmail(
        email: 'fail@fitbit.com',
      );
      expect(success, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('startPhoneAuth and verifySmsCode flow', () async {
      bool codeSentTriggered = false;

      await viewModel.startPhoneAuth(
        phoneNumber: '+15551234567',
        firstName: 'PhoneAthlete',
        onCodeSent: () => codeSentTriggered = true,
      );

      expect(codeSentTriggered, isTrue);
      expect(viewModel.verificationId, equals('mock_verification_id_123'));
      expect(viewModel.pendingPhoneNumber, equals('+15551234567'));
      expect(viewModel.isPhoneLoading, isFalse);

      final verified = await viewModel.verifySmsCode(smsCode: '123456');
      expect(verified, isTrue);
      expect(viewModel.currentUser?.phoneNumber, equals('+1234567890'));
      expect(viewModel.currentUser?.displayName, equals('PhoneAthlete'));
      expect(viewModel.isPhoneLoading, isFalse);
    });

    test('verifySmsCode fails if no verificationId is active', () async {
      final verified = await viewModel.verifySmsCode(smsCode: '123456');
      expect(verified, isFalse);
      expect(viewModel.errorMessage, contains('No active phone verification'));
    });

    test(
      'loginWithGoogle logs in, sets greeting, and handles loading flag',
      () async {
        final success = await viewModel.loginWithGoogle();
        expect(success, isTrue);
        expect(viewModel.currentUser?.displayName, equals('Google Runner'));
        expect(viewModel.successMessage, contains('Google'));
        expect(viewModel.isGoogleLoading, isFalse);
      },
    );

    test('signOut clears currentUser and pending data', () async {
      await viewModel.loginWithEmail(
        email: 'alex@fitbit.com',
        password: 'password',
      );
      expect(viewModel.currentUser, isNotNull);

      await viewModel.signOut();
      expect(viewModel.currentUser, isNull);
      expect(viewModel.verificationId, isNull);
      expect(viewModel.pendingPhoneNumber, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('setErrorMessage and clearMessages update state', () {
      viewModel.setErrorMessage('Custom test error');
      expect(viewModel.errorMessage, equals('Custom test error'));

      viewModel.clearMessages();
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.successMessage, isNull);
    });
  });
}
