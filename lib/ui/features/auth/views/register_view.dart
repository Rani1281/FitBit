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
import 'email_verification_view.dart';
import 'sms_code_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.viewModel});

  final AuthViewModel viewModel;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _firstNameEmailController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _firstNamePhoneController = TextEditingController();
  final _phoneController = TextEditingController(text: '+1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameEmailController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNamePhoneController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailRegister() async {
    widget.viewModel.clearMessages();
    if (!_emailFormKey.currentState!.validate()) {
      // widget.viewModel.setErrorMessage(
      //   'Please check the highlighted fields below.',
      // );
      return;
    }

    final success = await widget.viewModel.registerWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameEmailController.text,
    );

    if (mounted && success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EmailVerificationView(viewModel: widget.viewModel),
        ),
      );
    }
  }

  Future<void> _handlePhoneRegister() async {
    widget.viewModel.clearMessages();
    if (!_phoneFormKey.currentState!.validate()) {
      // widget.viewModel.setErrorMessage(
      //   'Please check the highlighted fields below.',
      // );
      return;
    }

    final phone = _phoneController.text.trim();
    await widget.viewModel.startPhoneAuth(
      phoneNumber: phone,
      firstName: _firstNamePhoneController.text.trim(),
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
    final success = await widget.viewModel.loginWithGoogle();
    if (mounted && success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            widget.viewModel.clearMessages();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space24,
                  vertical: AppDimensions.space16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Start your journey',
                        style: AppTextStyles.headingLarge,
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      const Text(
                        'Create a new account',
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
                          ? _buildEmailRegisterForm()
                          : _buildPhoneRegisterForm(),
                      const SizedBox(height: AppDimensions.space12),
                      _buildDivider(),
                      const SizedBox(height: AppDimensions.space12),
                      SocialAuthButton(
                        text: 'Sign up with Google',
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
                            'Already have an account? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.viewModel.clearMessages();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Sign In',
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

  Widget _buildEmailRegisterForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'First Name',
            hint: 'Enter your first name',
            controller: _firstNameEmailController,
            prefixIcon: Icons.person_outline_rounded,
            validator: Validators.validateFirstName,
          ),
          const SizedBox(height: AppDimensions.space12),
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: AppDimensions.space12),
          CustomTextField(
            label: 'Password',
            hint: 'Create a strong password',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: AppDimensions.space12),
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Enter password again',
            controller: _confirmPasswordController,
            isPassword: true,
            prefixIcon: Icons.lock_reset_rounded,
            validator: (val) => Validators.validateConfirmPassword(
              _passwordController.text,
              val,
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleEmailRegister(),
          ),
          const SizedBox(height: AppDimensions.space20),
          PrimaryButton(
            text: 'Create Account',
            isLoading: widget.viewModel.isEmailLoading,
            onPressed: widget.viewModel.isLoading ? null : _handleEmailRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRegisterForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'First Name',
            hint: 'Jordan',
            controller: _firstNamePhoneController,
            prefixIcon: Icons.person_outline_rounded,
            validator: Validators.validateFirstName,
          ),
          const SizedBox(height: AppDimensions.space16),
          CustomTextField(
            label: 'Phone Number (International)',
            hint: '+1234567890',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_rounded,
            validator: Validators.validatePhoneNumber,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handlePhoneRegister(),
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
                  Icons.info_outline_rounded,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
                SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    'We will send a 6-digit SMS verification code to verify your phone number.',
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
            text: 'Send SMS Verification',
            isLoading: widget.viewModel.isPhoneLoading,
            onPressed: widget.viewModel.isLoading ? null : _handlePhoneRegister,
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
              color: AppColors.textMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
