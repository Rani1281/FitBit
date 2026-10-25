import 'package:fitbit/domain/models/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserEntity Unit Tests', () {
    test('firstName extracts first token from displayName', () {
      const user = UserEntity(id: 'u1', displayName: 'Johnathan Doe');
      expect(user.firstName, equals('Johnathan'));
    });

    test(
      'firstName extracts username if displayName is null but email exists',
      () {
        const user = UserEntity(id: 'u2', email: 'marathon_runner@fitbit.com');
        expect(user.firstName, equals('marathon_runner'));
      },
    );

    test(
      'firstName falls back to phone number if name and email are missing',
      () {
        const user = UserEntity(id: 'u3', phoneNumber: '+14155552671');
        expect(user.firstName, equals('+14155552671'));
      },
    );

    test('firstName falls back to Athlete when all identifiers are absent', () {
      const user = UserEntity(id: 'u4');
      expect(user.firstName, equals('Athlete'));
    });

    test(
      'providerDisplayName returns appropriate labels for each provider',
      () {
        const emailUser = UserEntity(
          id: '1',
          providerType: AuthProviderType.email,
        );
        const phoneUser = UserEntity(
          id: '2',
          providerType: AuthProviderType.phone,
        );
        const googleUser = UserEntity(
          id: '3',
          providerType: AuthProviderType.google,
        );
        const unknownUser = UserEntity(
          id: '4',
          providerType: AuthProviderType.unknown,
        );

        expect(emailUser.providerDisplayName, equals('Email & Password'));
        expect(phoneUser.providerDisplayName, equals('Phone Number'));
        expect(googleUser.providerDisplayName, equals('Google Sign-In'));
        expect(unknownUser.providerDisplayName, equals('Firebase Auth'));
      },
    );

    test('copyWith updates specified fields while keeping original values', () {
      const original = UserEntity(
        id: 'u1',
        email: 'original@fitbit.com',
        displayName: 'Sam Runner',
        isEmailVerified: false,
        providerType: AuthProviderType.email,
      );

      final updated = original.copyWith(
        isEmailVerified: true,
        displayName: 'Sam Champion',
      );

      expect(updated.id, equals('u1'));
      expect(updated.email, equals('original@fitbit.com'));
      expect(updated.displayName, equals('Sam Champion'));
      expect(updated.isEmailVerified, isTrue);
      expect(updated.providerType, equals(AuthProviderType.email));
    });
  });
}
