import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../ui/core/utils/validators.dart';
import '../../domain/models/user_entity.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  UserEntity? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw 'Authentication failed: User account not found.';
      }
      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign in: $e';
    }
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw 'Registration failed: Unable to create user.';
      }

      final trimmedName = firstName.trim();
      if (trimmedName.isNotEmpty) {
        await user.updateDisplayName(trimmedName);
      }

      try {
        await user.sendEmailVerification();
      } catch (_) {
        // Continue even if initial email verification trigger fails
      }

      await user.reload();
      return _mapFirebaseUser(_auth.currentUser ?? user)!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during registration: $e';
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'No user is currently signed in.';
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Failed to send verification email: $e';
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email: $e';
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(UserEntity user) onAutoVerified,
    int? resendToken,
  }) async {
    final normalized = Validators.normalizePhoneNumber(phoneNumber);
    if (normalized.isEmpty || !normalized.startsWith('+')) {
      onError(
        'Please include your country code starting with + (e.g. +1 555 123 4567).',
      );
      return;
    }
    if (normalized.length < 9) {
      onError(
        'The phone number entered is too short. Please include your country code and number.',
      );
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: normalized,
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCred = await _auth.signInWithCredential(credential);
            if (userCred.user != null) {
              onAutoVerified(_mapFirebaseUser(userCred.user)!);
            }
          } catch (e) {
            onError('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_handleFirebaseAuthException(e));
        },
        codeSent: (String verificationId, int? token) {
          onCodeSent(verificationId, token);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout reached for automatic SMS retrieval
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError('Failed to initiate phone verification: $e');
    }
  }

  @override
  Future<UserEntity> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
    String? firstName,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) {
        throw 'Failed to sign in with SMS verification code.';
      }

      if (firstName != null && firstName.trim().isNotEmpty) {
        await user.updateDisplayName(firstName.trim());
        await user.reload();
      }

      return _mapFirebaseUser(_auth.currentUser ?? user)!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An error occurred during SMS verification: $e';
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In was cancelled by the user.';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        throw 'Google Sign-In failed: No user returned.';
      }

      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        throw 'Google sign-in was cancelled.';
      }
      throw 'Google Sign-In failed: $e';
    }
  }

  @override
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (_) {
      await _auth.signOut();
    }
  }

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;

    AuthProviderType providerType = AuthProviderType.unknown;
    for (final info in user.providerData) {
      if (info.providerId == 'google.com') {
        providerType = AuthProviderType.google;
        break;
      } else if (info.providerId == 'phone') {
        providerType = AuthProviderType.phone;
        break;
      } else if (info.providerId == 'password') {
        providerType = AuthProviderType.email;
        break;
      }
    }

    if (providerType == AuthProviderType.unknown) {
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        providerType = AuthProviderType.phone;
      } else if (user.email != null && user.email!.isNotEmpty) {
        providerType = AuthProviderType.email;
      }
    }

    return UserEntity(
      id: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      providerType: providerType,
    );
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    debugPrint(
      '==================== FIREBASE AUTH EXCEPTION ====================',
    );
    debugPrint('Code: ${e.code}');
    debugPrint('Message: ${e.message}');
    debugPrint('Plugin: ${e.plugin}');
    debugPrint('Full Exception: $e');
    if (e.stackTrace != null) {
      debugPrint('Stack Trace: ${e.stackTrace}');
    }
    debugPrint(
      '=================================================================',
    );

    switch (e.code) {
      case 'user-not-found':
        return 'No account was found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address format is not valid. Please enter a valid email (e.g. name@example.com).';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      // case 'operation-not-allowed':
      //   return 'This sign-in method is currently disabled. Please contact support or try a different method.';
      case 'invalid-verification-code':
        return 'The 6-digit SMS verification code entered is incorrect.';
      case 'invalid-verification-id':
        return 'The verification session has expired. Try resending the code.';
      case 'session-expired':
        return 'Your verification session has expired. Try resending the code';
      case 'invalid-phone-number':
        return 'The phone number entered is invalid. Please enter a valid one (e.g. +1 555 123 4567).';
      case 'missing-phone-number':
        return 'Please enter a phone number to continue.';
      // case 'quota-exceeded':
      //   return 'SMS limit reached. Please try again later or use Google/Email sign-in.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your internet connection and try again.';
      // case 'app-not-authorized':
      // case 'missing-client-identifier':
      // case 'app-verification-failed':
      //   return 'Device verification failed. Please check your internet connection and Google Play Services.';
      // case 'captcha-check-failed':
      //   return 'Security check could not be completed. Please try again.';
      case 'credential-already-in-use':
        return 'This phone number or credential is already linked to another account.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'popup-closed-by-user':
        return 'Sign-in window was closed before completing sign-in.';
      default:
        return "Something went wrong";
    }
  }
}
