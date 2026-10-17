import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../ui/core/constants/app_colors.dart';
import '../../../../ui/core/constants/app_dimensions.dart';
import '../../../../ui/core/constants/app_text_styles.dart';
import '../../../../ui/core/utils/validators.dart';
import '../../../../ui/core/widgets/custom_text_field.dart';
import '../../../../ui/core/widgets/primary_button.dart';
import '../view_models/auth_view_model.dart';

class SmsCodeView extends StatefulWidget {
  const SmsCodeView({
    super.key,
    required this.viewModel,
    required this.phoneNumber,
  });

  final AuthViewModel viewModel;
  final String phoneNumber;

  @override
  State<SmsCodeView> createState() => _SmsCodeViewState();
}

class _SmsCodeViewState extends State<SmsCodeView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Timer? _countdownTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.verifySmsCode(
      smsCode: _codeController.text,
    );

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

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0) return;

    await widget.viewModel.resendPhoneCode(
      onCodeSent: () {
        if (mounted) {
          _startCountdown();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('New code sent to ${widget.phoneNumber}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sms_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space24),
                        const Text(
                          'SMS Verification',
                          style: AppTextStyles.headingLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Text(
                          'Enter the 6-digit verification code sent to\n${widget.phoneNumber}',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.space32),
                        CustomTextField(
                          label: '6-Digit Code',
                          hint: '123456',
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.lock_clock_outlined,
                          validator: Validators.validateSmsCode,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleVerify(),
                        ),
                        const SizedBox(height: AppDimensions.space24),
                        PrimaryButton(
                          text: 'Verify & Sign In',
                          isLoading: widget.viewModel.isLoading,
                          onPressed: _handleVerify,
                        ),
                        const SizedBox(height: AppDimensions.space20),
                        Center(
                          child: TextButton(
                            onPressed: _secondsRemaining == 0
                                ? _handleResend
                                : null,
                            child: Text(
                              _secondsRemaining > 0
                                  ? 'Resend code in ${_secondsRemaining}s'
                                  : 'Resend Verification Code',
                              style: TextStyle(
                                color: _secondsRemaining == 0
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
