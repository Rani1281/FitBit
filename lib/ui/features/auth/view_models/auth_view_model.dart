import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/models/user_entity.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
    // ignore: prefer_initializing_formals
    : _authRepository = authRepository {
    _init();
  }

  final AuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Phone Authentication temporary state
  String? _verificationId;
  String? get verificationId => _verificationId;

  int? _resendToken;
  String? _pendingPhoneNumber;
  String? get pendingPhoneNumber => _pendingPhoneNumber;

  String? _pendingFirstName;
  String? get pendingFirstName => _pendingFirstName;

  void _init() {
    _currentUser = _authRepository.currentUser;
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearErrors();
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = user;
      _successMessage = 'Signed in successfully!';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
  }) async {
    _setLoading(true);
    _clearErrors();
    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
      );
      _currentUser = user;
      _successMessage =
          'Account created! A verification email has been sent to $email.';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearErrors();
    try {
      await _authRepository.sendEmailVerification();
      _successMessage = 'Verification link sent to your email!';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    _clearErrors();
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      _successMessage = 'Password reset instructions sent to $email';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startPhoneAuth({
    required String phoneNumber,
    String? firstName,
    required void Function() onCodeSent,
  }) async {
    _setLoading(true);
    _clearErrors();
    _pendingPhoneNumber = phoneNumber;
    _pendingFirstName = firstName;

    await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      resendToken: _resendToken,
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _setLoading(false);
        _successMessage = 'Verification code sent to $phoneNumber';
        onCodeSent();
      },
      onError: (error) {
        _setLoading(false);
        _errorMessage = error;
        notifyListeners();
      },
      onAutoVerified: (user) {
        _currentUser = user;
        _setLoading(false);
        _successMessage = 'Phone verified automatically!';
        notifyListeners();
      },
    );
  }

  Future<bool> verifySmsCode({required String smsCode}) async {
    if (_verificationId == null) {
      _errorMessage = 'No active phone verification session found.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearErrors();
    try {
      final user = await _authRepository.signInWithSmsCode(
        verificationId: _verificationId!,
        smsCode: smsCode,
        firstName: _pendingFirstName,
      );
      _currentUser = user;
      _successMessage = 'Phone number verified successfully!';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendPhoneCode({required void Function() onCodeSent}) async {
    if (_pendingPhoneNumber == null) return false;
    await startPhoneAuth(
      phoneNumber: _pendingPhoneNumber!,
      firstName: _pendingFirstName,
      onCodeSent: onCodeSent,
    );
    return true;
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _clearErrors();
    try {
      final user = await _authRepository.signInWithGoogle();
      _currentUser = user;
      _successMessage = 'Welcome back, ${user.firstName}!';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadUser() async {
    try {
      await _authRepository.reloadUser();
      _currentUser = _authRepository.currentUser;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _currentUser = null;
      _verificationId = null;
      _pendingPhoneNumber = null;
      _pendingFirstName = null;
      _successMessage = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrors() {
    _errorMessage = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
