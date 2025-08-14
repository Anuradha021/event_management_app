import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool isElevated;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? customShadow;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isElevated = false,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.customShadow,
  });

  const ModernCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.customShadow,
  }) : isElevated = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusM),
        border: border,
        boxShadow: customShadow ?? (isElevated ? AppTheme.elevatedShadow : AppTheme.cardShadow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusM),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Enhanced list item card with modern styling
class ModernListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Widget>? additionalInfo;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final Widget? trailing;
  final Color? backgroundColor;

  const ModernListCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.additionalInfo,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.trailing,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Row(
        children: [
          // Icon container with modern styling
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.1),
                  iconColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: iconColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppTheme.spacingM),
          
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (additionalInfo != null && additionalInfo!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...additionalInfo!,
                ],
              ],
            ),
          ),
          
          // Actions or trailing widget
          if (trailing != null)
            trailing!
          else if (showActions && (onEdit != null || onDelete != null))
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    onPressed: onEdit!,
                    tooltip: 'Edit',
                    color: AppTheme.primaryColor,
                  ),
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    onPressed: onDelete!,
                    tooltip: 'Delete',
                    color: AppTheme.errorColor,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

/// Action button for cards
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        tooltip: tooltip,
        color: color,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

/// Status badge component
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.backgroundColor,
    this.icon,
  });

  const StatusBadge.success({
    super.key,
    required this.text,
    this.icon,
  }) : color = AppTheme.successColor, backgroundColor = null;

  const StatusBadge.warning({
    super.key,
    required this.text,
    this.icon,
  }) : color = AppTheme.warningColor, backgroundColor = null;

  const StatusBadge.error({
    super.key,
    required this.text,
    this.icon,
  }) : color = AppTheme.errorColor, backgroundColor = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
