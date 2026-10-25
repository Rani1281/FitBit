import 'package:flutter/material.dart';

import '../../../../ui/core/constants/app_colors.dart';
import '../../../../ui/core/constants/app_dimensions.dart';
import '../../../../ui/core/constants/app_text_styles.dart';
import '../../../../ui/core/utils/validators.dart';
import '../../../../ui/core/widgets/custom_text_field.dart';
import '../../../../ui/core/widgets/inline_feedback_banner.dart';
import '../../../../ui/core/widgets/primary_button.dart';
import '../../../../ui/core/widgets/social_auth_button.dart';
import '../view_models/auth_view_model.dart';
import 'forgot_password_view.dart';
import 'register_view.dart';
import 'sms_code_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.viewModel});

  final AuthViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(text: '+1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    widget.viewModel.clearMessages();
    if (!_emailFormKey.currentState!.validate()) {
      // widget.viewModel.setErrorMessage(
      //   'Please check the highlighted fields below.',
      // );
      return;
    }

    await widget.viewModel.loginWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _handlePhoneLogin() async {
    widget.viewModel.clearMessages();
    if (!_phoneFormKey.currentState!.validate()) {
      widget.viewModel.setErrorMessage('Please enter a valid phone number.');
      return;
    }

    final phone = _phoneController.text.trim();
    await widget.viewModel.startPhoneAuth(
      phoneNumber: phone,
      onCodeSent: () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  SmsCodeView(viewModel: widget.viewModel, phoneNumber: phone),
            ),
          );
        }
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    widget.viewModel.clearMessages();
    await widget.viewModel.loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space24,
                  vertical: AppDimensions.space20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: AppTextStyles.headingLarge,
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      const Text(
                        'Log into your account',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      InlineFeedbackBanner(
                        message: widget.viewModel.errorMessage,
                        type: FeedbackType.error,
                        onDismiss: () => widget.viewModel.clearMessages(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium - 2,
                            ),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          onTap: (index) {
                            widget.viewModel.clearMessages();
                            _emailFormKey.currentState?.reset();
                            _phoneFormKey.currentState?.reset();
                            setState(() {});
                          },
                          tabs: const [
                            Tab(text: 'Email', height: 35),
                            Tab(text: 'Phone', height: 35),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      _tabController.index == 0
                          ? _buildEmailLoginForm()
                          : _buildPhoneLoginForm(),
                      const SizedBox(height: AppDimensions.space12),
                      _buildDivider(),
                      const SizedBox(height: AppDimensions.space12),
                      SocialAuthButton(
                        text: 'Continue with Google',
                        isLoading: widget.viewModel.isGoogleLoading,
                        onPressed: widget.viewModel.isLoading
                            ? null
                            : _handleGoogleSignIn,
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.viewModel.clearMessages();
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => RegisterView(
                                        viewModel: widget.viewModel,
                                      ),
                                    ),
                                  )
                                  .then((_) {
                                    if (mounted) {
                                      widget.viewModel.clearMessages();
                                    }
                                  });
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmailLoginForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Email Address',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: AppDimensions.space12),
          CustomTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
            validator: Validators.validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleEmailLogin(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                widget.viewModel.clearMessages();
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ForgotPasswordView(viewModel: widget.viewModel),
                      ),
                    )
                    .then((_) {
                      if (mounted) {
                        widget.viewModel.clearMessages();
                      }
                    });
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          PrimaryButton(
            text: 'Sign In',
            isLoading: widget.viewModel.isEmailLoading,
            onPressed: widget.viewModel.isLoading ? null : _handleEmailLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLoginForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Phone Number (International)',
            hint: '+1234567890',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_rounded,
            validator: Validators.validatePhoneNumber,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handlePhoneLogin(),
          ),
          const SizedBox(height: AppDimensions.space12),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
                SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    'We will send a one-time SMS verification code to verify your phone number.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),
          PrimaryButton(
            text: 'Send Verification Code',
            isLoading: widget.viewModel.isPhoneLoading,
            onPressed: widget.viewModel.isLoading ? null : _handlePhoneLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
          ),
          child: Text(
            'OR',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
