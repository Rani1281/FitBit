import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../ui/core/constants/app_colors.dart';
import '../../../../ui/core/constants/app_dimensions.dart';
import '../../../../ui/core/constants/app_text_styles.dart';
import '../../../../ui/core/widgets/inline_feedback_banner.dart';
import '../../../../ui/core/widgets/secondary_button.dart';
import '../view_models/auth_view_model.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key, required this.viewModel});

  final AuthViewModel viewModel;

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  Timer? _countdownTimer;
  Timer? _autoCheckTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startAutoVerificationTimer();
  }

  void _startAutoVerificationTimer() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await widget.viewModel.reloadUser();
      if (mounted) {
        final user = widget.viewModel.currentUser;
        if (user != null && user.isEmailVerified) {
          timer.cancel();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 60;
    });
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

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0) return;
    widget.viewModel.clearMessages();

    final success = await widget.viewModel.sendEmailVerification();
    if (mounted && success) {
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              _autoCheckTimer?.cancel();
              widget.viewModel.clearMessages();
              await widget.viewModel.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final email = widget.viewModel.currentUser?.email ?? 'your email';

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
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      const Text(
                        'Verify Your Email',
                        style: AppTextStyles.headingLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'We have sent an email verification link to\n',
                            ),
                            TextSpan(
                              text: email,
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '.\nPlease check your inbox and tap the link. This screen will automatically continue once verified.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space20),
                      InlineFeedbackBanner(
                        message: widget.viewModel.errorMessage,
                        type: FeedbackType.error,
                        onDismiss: () => widget.viewModel.clearMessages(),
                      ),
                      SecondaryButton(
                        text: _secondsRemaining > 0
                            ? 'Resend email in ${_secondsRemaining}s'
                            : 'Resend Verification Email',
                        onPressed: _secondsRemaining == 0
                            ? _handleResend
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      Center(
                        child: Tooltip(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 5),
                          message:
                              'Email verification confirms you own your email address and '
                              'helps you securely recover your account if you forget your password.',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Why should I verify my email?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.dotted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            _autoCheckTimer?.cancel();
                            widget.viewModel.clearMessages();
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
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
}
