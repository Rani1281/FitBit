import '../../domain/models/user_entity.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository({required AuthService authService})
    // ignore: prefer_initializing_formals
    : _authService = authService;

  final AuthService _authService;

  Stream<UserEntity?> get authStateChanges => _authService.authStateChanges;

  UserEntity? get currentUser => _authService.currentUser;

  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
  }) {
    return _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
      firstName: firstName,
    );
  }

  Future<void> sendEmailVerification() {
    return _authService.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(UserEntity user) onAutoVerified,
    int? resendToken,
  }) {
    return _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerified: onAutoVerified,
      resendToken: resendToken,
    );
  }

  Future<UserEntity> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
    String? firstName,
  }) {
    return _authService.signInWithSmsCode(
      verificationId: verificationId,
      smsCode: smsCode,
      firstName: firstName,
    );
  }

  Future<UserEntity> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<void> reloadUser() {
    return _authService.reloadUser();
  }

  Future<void> signOut() {
    return _authService.signOut();
  }
}
