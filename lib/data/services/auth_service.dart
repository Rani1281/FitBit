import '../../domain/models/user_entity.dart';

abstract class AuthService {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;

  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
  });

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(UserEntity user) onAutoVerified,
    int? resendToken,
  });

  Future<UserEntity> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
    String? firstName,
  });

  Future<UserEntity> signInWithGoogle();

  Future<void> reloadUser();

  Future<void> signOut();
}
