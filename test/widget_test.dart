import 'dart:async';

import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:fitbit/data/services/auth_service.dart';
import 'package:fitbit/domain/models/user_entity.dart';
import 'package:fitbit/main.dart';
import 'package:fitbit/ui/features/auth/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthService implements AuthService {
  MockAuthService({this.initialUser});

  final UserEntity? initialUser;
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  UserEntity? get currentUser => initialUser;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = UserEntity(
      id: 'test_uid',
      email: email,
      displayName: 'Test Athlete',
      isEmailVerified: true,
      providerType: AuthProviderType.email,
    );
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
  }) async {
    final user = UserEntity(
      id: 'new_uid',
      email: email,
      displayName: firstName,
      isEmailVerified: false,
      providerType: AuthProviderType.email,
    );
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final user = const UserEntity(
      id: 'google_uid',
      email: 'google@fitbit.com',
      displayName: 'Google User',
      isEmailVerified: true,
      providerType: AuthProviderType.google,
    );
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
    String? firstName,
  }) async {
    final user = UserEntity(
      id: 'phone_uid',
      phoneNumber: '+1234567890',
      displayName: firstName ?? 'Phone User',
      providerType: AuthProviderType.phone,
    );
    _controller.add(user);
    return user;
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(UserEntity user) onAutoVerified,
    int? resendToken,
  }) async {
    onCodeSent('test_verification_id', 1234);
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> reloadUser() async {}

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }
}

void main() {
  testWidgets('Renders LoginView when unauthenticated', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockAuthService(initialUser: null);
    final repository = AuthRepository(authService: mockAuth);
    final viewModel = AuthViewModel(authRepository: repository);

    await tester.pumpWidget(MyApp(authViewModel: viewModel));
    await tester.pumpAndSettle();

    expect(find.text('Sign In with Email'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Renders Dashboard and increments steps when authenticated', (
    WidgetTester tester,
  ) async {
    const user = UserEntity(
      id: 'user_123',
      email: 'athlete@fitbit.com',
      displayName: 'Taylor',
      isEmailVerified: true,
      providerType: AuthProviderType.email,
    );

    final mockAuth = MockAuthService(initialUser: user);
    final repository = AuthRepository(authService: mockAuth);
    final viewModel = AuthViewModel(authRepository: repository);

    await tester.pumpWidget(MyApp(authViewModel: viewModel));
    await tester.pumpAndSettle();

    expect(find.text('FitBit Dashboard'), findsOneWidget);
    expect(find.text('Hello, Taylor!'), findsOneWidget);
    expect(find.text('Steps Taken Today'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('1000'), findsOneWidget);
  });
}
