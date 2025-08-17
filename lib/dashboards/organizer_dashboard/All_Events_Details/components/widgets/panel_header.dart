import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/modern_button.dart';


class PanelHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onCreatePressed;
  final String? createTooltip;
  final bool canCreate;
  final IconData? titleIcon;
  final Widget? trailing;

  const PanelHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onCreatePressed,
    this.createTooltip,
    this.canCreate = true,
    this.titleIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.05),
            AppTheme.primaryColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
        
          Expanded(
            child: Row(
              children: [
                if (titleIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Icon(
                      titleIcon,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.headingSmall,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          if (trailing != null)
            trailing!
          else if (onCreatePressed != null)
            ModernButton(
              text: 'Create',
              icon: Icons.add,
              onPressed: canCreate ? onCreatePressed : null,
              size: ModernButtonSize.medium,
              style: canCreate ? ModernButtonStyle.primary : ModernButtonStyle.outline,
            ),
        ],
      ),
    );
  }
}
