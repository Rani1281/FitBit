import 'package:fitbit/ui/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators Test Suite', () {
    test('normalizePhoneNumber removes spaces, dashes, and parentheses', () {
      expect(
        Validators.normalizePhoneNumber('+1 (650) 555-1234'),
        equals('+16505551234'),
      );
      expect(
        Validators.normalizePhoneNumber('+44 7911-123456'),
        equals('+447911123456'),
      );
      expect(Validators.normalizePhoneNumber(null), equals(''));
    });

    test('validateFirstName checks emptiness, length and characters', () {
      expect(Validators.validateFirstName(''), isNotNull);
      expect(Validators.validateFirstName('A'), isNotNull);
      expect(Validators.validateFirstName('123'), isNotNull);
      expect(Validators.validateFirstName('Alex'), isNull);
      expect(Validators.validateFirstName("Mary-Jane O'Connor"), isNull);
    });

    test('validateEmail validates proper email formatting', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('validatePassword enforces minimum 6 characters', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('validateConfirmPassword checks matching passwords', () {
      expect(Validators.validateConfirmPassword('secret123', ''), isNotNull);
      expect(
        Validators.validateConfirmPassword('secret123', 'wrong'),
        isNotNull,
      );
      expect(
        Validators.validateConfirmPassword('secret123', 'secret123'),
        isNull,
      );
    });

    test('validatePhoneNumber checks country code, length, and format', () {
      expect(
        Validators.validatePhoneNumber(''),
        equals('Phone number is required'),
      );
      expect(
        Validators.validatePhoneNumber('1234567890'),
        contains('include country code with +'),
      );
      expect(
        Validators.validatePhoneNumber('+12345'),
        contains('Phone number is too short'),
      );
      expect(
        Validators.validatePhoneNumber('+1234567890123456789'),
        contains('Phone number is too long'),
      );
      expect(Validators.validatePhoneNumber('+1234567890'), isNull);
      expect(Validators.validatePhoneNumber('+1 (650) 555-1234'), isNull);
      expect(Validators.validatePhoneNumber('+447911123456'), isNull);
    });

    test('validateSmsCode checks 6 digits', () {
      expect(Validators.validateSmsCode(''), isNotNull);
      expect(Validators.validateSmsCode('12345'), isNotNull);
      expect(Validators.validateSmsCode('1234567'), isNotNull);
      expect(Validators.validateSmsCode('abcdef'), isNotNull);
      expect(Validators.validateSmsCode('123456'), isNull);
    });
  });
}
