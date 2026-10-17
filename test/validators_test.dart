import 'package:fitbit/ui/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators Test Suite', () {
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

    test('validatePhoneNumber checks international E.164 format', () {
      expect(Validators.validatePhoneNumber(''), isNotNull);
      expect(Validators.validatePhoneNumber('12345'), isNotNull);
      expect(Validators.validatePhoneNumber('+1234567890'), isNull);
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
