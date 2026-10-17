import 'package:flutter/material.dart';

import '../../../../ui/core/constants/app_colors.dart';
import '../../../../ui/core/constants/app_dimensions.dart';
import '../../../../ui/core/constants/app_text_styles.dart';
import '../../../../ui/core/utils/validators.dart';
import '../../../../ui/core/widgets/app_logo.dart';
import '../../../../ui/core/widgets/custom_text_field.dart';
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
    if (!_emailFormKey.currentState!.validate()) return;

    final success = await widget.viewModel.registerWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameEmailController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EmailVerificationView(viewModel: widget.viewModel),
          ),
        );
      } else if (widget.viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handlePhoneRegister() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    await widget.viewModel.startPhoneAuth(
      phoneNumber: _phoneController.text.trim(),
      firstName: _firstNamePhoneController.text.trim(),
      onCodeSent: () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SmsCodeView(
                viewModel: widget.viewModel,
                phoneNumber: _phoneController.text.trim(),
              ),
            ),
          );
        }
      },
    );

    if (mounted && widget.viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await widget.viewModel.loginWithGoogle();
    if (mounted) {
      if (success) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (widget.viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
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
                      const AppLogo(size: 52, showTagline: false),
                      const SizedBox(height: AppDimensions.space16),
                      const Text(
                        'Join FitBit',
                        style: AppTextStyles.headingLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      const Text(
                        'Create an account to track your workouts and reach your goals',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.space24),
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
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.email_outlined, size: 18),
                              text: 'Email',
                            ),
                            Tab(
                              icon: Icon(Icons.phone_iphone_rounded, size: 18),
                              text: 'Phone',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      SizedBox(
                        height: 440,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildEmailRegisterForm(),
                            _buildPhoneRegisterForm(),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      _buildDivider(),
                      const SizedBox(height: AppDimensions.space16),
                      SocialAuthButton(
                        text: 'Sign up with Google',
                        isLoading: widget.viewModel.isLoading,
                        onPressed: _handleGoogleSignIn,
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
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
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          CustomTextField(
            label: 'First Name',
            hint: 'Alex',
            controller: _firstNameEmailController,
            prefixIcon: Icons.person_outline_rounded,
            validator: Validators.validateFirstName,
          ),
          const SizedBox(height: AppDimensions.space12),
          CustomTextField(
            label: 'Email',
            hint: 'alex@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: AppDimensions.space12),
          CustomTextField(
            label: 'Password',
            hint: 'At least 6 characters',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: AppDimensions.space12),
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Repeat your password',
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
            isLoading: widget.viewModel.isLoading,
            onPressed: _handleEmailRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRegisterForm() {
    return Form(
      key: _phoneFormKey,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
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
            isLoading: widget.viewModel.isLoading,
            onPressed: _handlePhoneRegister,
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
