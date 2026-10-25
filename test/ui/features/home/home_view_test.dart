import 'package:fitbit/data/repositories/auth_repository.dart';
import 'package:fitbit/domain/models/user_entity.dart';
import 'package:fitbit/ui/features/auth/view_models/auth_view_model.dart';
import 'package:fitbit/ui/features/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/mock_auth_service.dart';

void main() {
  group('HomeView Widget Tests', () {
    late MockAuthService mockService;
    late AuthRepository repository;
    late AuthViewModel viewModel;

    const testUser = UserEntity(
      id: 'uid_ath_101',
      email: 'alex.champion@fitbit.com',
      displayName: 'Alex Champion',
      phoneNumber: '+15550001111',
      isEmailVerified: true,
      providerType: AuthProviderType.google,
    );

    setUp(() {
      mockService = MockAuthService(initialUser: testUser);
      repository = AuthRepository(authService: mockService);
      viewModel = AuthViewModel(authRepository: repository);
    });

    tearDown(() {
      viewModel.dispose();
      mockService.dispose();
    });

    Widget createTestWidget({UserEntity? customUser}) {
      if (customUser != null) {
        mockService = MockAuthService(initialUser: customUser);
        repository = AuthRepository(authService: mockService);
        viewModel = AuthViewModel(authRepository: repository);
      }
      return MaterialApp(home: HomeView(viewModel: viewModel));
    }

    testWidgets('renders dashboard with user greeting, stats, and badges', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('FitBit Dashboard'), findsOneWidget);
      expect(find.text('Hello, Alex!'), findsOneWidget);
      expect(find.text('alex.champion@fitbit.com'), findsNWidgets(2));
      expect(find.text('Google Sign-In'), findsOneWidget);
      expect(find.text('Steps Taken Today'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('Active Time'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('Account Information'), findsOneWidget);
      expect(find.text('uid_ath_101'), findsOneWidget);
    });

    testWidgets('increments and resets steps counter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('1000'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
      expect(find.text('40 kcal'), findsOneWidget);
      expect(find.text('10 mins'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('shows warning banner when email is unverified', (
      WidgetTester tester,
    ) async {
      const unverifiedUser = UserEntity(
        id: 'unverified_uid',
        email: 'unverified@fitbit.com',
        displayName: 'Unverified User',
        isEmailVerified: false,
        providerType: AuthProviderType.email,
      );

      await tester.pumpWidget(createTestWidget(customUser: unverifiedUser));
      await tester.pumpAndSettle();

      expect(find.text('Your email is not verified yet.'), findsOneWidget);
      expect(find.text('Verify Now'), findsOneWidget);
    });

    testWidgets('opens sign out dialog and confirms logout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to sign out of your FitBit account?'),
        findsOneWidget,
      );

      // Confirm sign out in dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.pumpAndSettle();

      expect(mockService.signOutCalls, equals(1));
      expect(viewModel.currentUser, isNull);
    });
  });
}
