import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum FeedbackType { error, warning, success, info }

class InlineFeedbackBanner extends StatelessWidget {
  const InlineFeedbackBanner({
    super.key,
    required this.message,
    this.type = FeedbackType.error,
    this.onDismiss,
  });

  final String? message;
  final FeedbackType type;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;

    switch (type) {
      case FeedbackType.error:
        bgColor = AppColors.error.withValues(alpha: 0.15);
        borderColor = AppColors.error.withValues(alpha: 0.5);
        iconColor = AppColors.error;
        iconData = Icons.error_outline_rounded;
        break;
      case FeedbackType.warning:
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        borderColor = AppColors.warning.withValues(alpha: 0.5);
        iconColor = AppColors.warning;
        iconData = Icons.warning_amber_rounded;
        break;
      case FeedbackType.success:
        bgColor = AppColors.success.withValues(alpha: 0.15);
        borderColor = AppColors.success.withValues(alpha: 0.5);
        iconColor = AppColors.success;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case FeedbackType.info:
        bgColor = AppColors.primary.withValues(alpha: 0.15);
        borderColor = AppColors.primary.withValues(alpha: 0.5);
        iconColor = AppColors.primaryLight;
        iconData = Icons.info_outline_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppDimensions.space8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.6),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
