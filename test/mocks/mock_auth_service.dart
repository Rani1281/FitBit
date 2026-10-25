import 'dart:async';

import 'package:fitbit/data/services/auth_service.dart';
import 'package:fitbit/domain/models/user_entity.dart';

class MockAuthService implements AuthService {
  MockAuthService({this.initialUser}) {
    _currentUser = initialUser;
  }

  final UserEntity? initialUser;
  UserEntity? _currentUser;
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();

  // Control mock behavior
  bool shouldFail = false;
  String failureMessage = 'Mock error occurred';
  bool shouldAutoVerifyPhone = false;

  // Track method calls
  int signInEmailCalls = 0;
  int registerEmailCalls = 0;
  int sendEmailVerificationCalls = 0;
  int sendPasswordResetEmailCalls = 0;
  int verifyPhoneNumberCalls = 0;
  int signInWithSmsCodeCalls = 0;
  int signInWithGoogleCalls = 0;
  int reloadUserCalls = 0;
  int signOutCalls = 0;

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInEmailCalls++;
    if (shouldFail) throw failureMessage;
    _currentUser = UserEntity(
      id: 'mock_uid_1',
      email: email,
      displayName: 'Alex Athlete',
      isEmailVerified: true,
      providerType: AuthProviderType.email,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
  }) async {
    registerEmailCalls++;
    if (shouldFail) throw failureMessage;
    _currentUser = UserEntity(
      id: 'mock_uid_2',
      email: email,
      displayName: firstName,
      isEmailVerified: false,
      providerType: AuthProviderType.email,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> sendEmailVerification() async {
    sendEmailVerificationCalls++;
    if (shouldFail) throw failureMessage;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    sendPasswordResetEmailCalls++;
    if (shouldFail) throw failureMessage;
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(UserEntity user) onAutoVerified,
    int? resendToken,
  }) async {
    verifyPhoneNumberCalls++;
    if (shouldFail) {
      onError(failureMessage);
      return;
    }
    if (shouldAutoVerifyPhone) {
      _currentUser = UserEntity(
        id: 'mock_phone_auto_uid',
        phoneNumber: phoneNumber,
        displayName: 'Phone User',
        providerType: AuthProviderType.phone,
      );
      _controller.add(_currentUser);
      onAutoVerified(_currentUser!);
    } else {
      onCodeSent('mock_verification_id_123', 456);
    }
  }

  @override
  Future<UserEntity> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
    String? firstName,
  }) async {
    signInWithSmsCodeCalls++;
    if (shouldFail) throw failureMessage;
    _currentUser = UserEntity(
      id: 'mock_sms_uid',
      phoneNumber: '+1234567890',
      displayName: firstName ?? 'SMS User',
      isEmailVerified: false,
      providerType: AuthProviderType.phone,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    signInWithGoogleCalls++;
    if (shouldFail) throw failureMessage;
    _currentUser = const UserEntity(
      id: 'mock_google_uid',
      email: 'google.athlete@fitbit.com',
      displayName: 'Google Runner',
      isEmailVerified: true,
      providerType: AuthProviderType.google,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> reloadUser() async {
    reloadUserCalls++;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isEmailVerified: true);
      _controller.add(_currentUser);
    }
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
