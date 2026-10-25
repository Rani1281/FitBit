import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_auth_service.dart';

void main() {
  group('AuthRepository Unit Tests', () {
    late MockAuthService mockService;
    late AuthRepository repository;

    setUp(() {
      mockService = MockAuthService();
      repository = AuthRepository(authService: mockService);
    });

    tearDown(() {
      mockService.dispose();
    });

    test('delegates signInWithEmailAndPassword to service', () async {
      final user = await repository.signInWithEmailAndPassword(
        email: 'test@fitbit.com',
        password: 'password123',
      );

      expect(mockService.signInEmailCalls, equals(1));
      expect(user.email, equals('test@fitbit.com'));
      expect(repository.currentUser?.email, equals('test@fitbit.com'));
    });

    test('delegates registerWithEmailAndPassword to service', () async {
      final user = await repository.registerWithEmailAndPassword(
        email: 'register@fitbit.com',
        password: 'password123',
        firstName: 'Taylor',
      );

      expect(mockService.registerEmailCalls, equals(1));
      expect(user.displayName, equals('Taylor'));
      expect(user.isEmailVerified, isFalse);
    });

    test('delegates sendEmailVerification to service', () async {
      await repository.sendEmailVerification();
      expect(mockService.sendEmailVerificationCalls, equals(1));
    });

    test('delegates sendPasswordResetEmail to service', () async {
      await repository.sendPasswordResetEmail(email: 'reset@fitbit.com');
      expect(mockService.sendPasswordResetEmailCalls, equals(1));
    });

    test('delegates verifyPhoneNumber to service', () async {
      String? receivedVerId;
      await repository.verifyPhoneNumber(
        phoneNumber: '+1234567890',
        onCodeSent: (id, token) => receivedVerId = id,
        onError: (_) {},
        onAutoVerified: (_) {},
      );

      expect(mockService.verifyPhoneNumberCalls, equals(1));
      expect(receivedVerId, equals('mock_verification_id_123'));
    });

    test('delegates signInWithSmsCode to service', () async {
      final user = await repository.signInWithSmsCode(
        verificationId: 'mock_verification_id_123',
        smsCode: '123456',
        firstName: 'PhoneUser',
      );

      expect(mockService.signInWithSmsCodeCalls, equals(1));
      expect(user.phoneNumber, equals('+1234567890'));
      expect(user.displayName, equals('PhoneUser'));
    });

    test('delegates signInWithGoogle to service', () async {
      final user = await repository.signInWithGoogle();
      expect(mockService.signInWithGoogleCalls, equals(1));
      expect(user.displayName, equals('Google Runner'));
    });

    test('delegates reloadUser to service', () async {
      await repository.signInWithEmailAndPassword(
        email: 'test@fitbit.com',
        password: 'pass',
      );
      await repository.reloadUser();
      expect(mockService.reloadUserCalls, equals(1));
    });

    test('delegates signOut to service', () async {
      await repository.signOut();
      expect(mockService.signOutCalls, equals(1));
      expect(repository.currentUser, isNull);
    });
  });
}
