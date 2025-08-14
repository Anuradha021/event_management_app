import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ModernButtonStyle style;
  final ModernButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.style = ModernButtonStyle.primary,
    this.size = ModernButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  const ModernButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.size = ModernButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : style = ModernButtonStyle.primary;

  const ModernButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.size = ModernButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : style = ModernButtonStyle.secondary;

  const ModernButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.size = ModernButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : style = ModernButtonStyle.outline;

  const ModernButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.size = ModernButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : style = ModernButtonStyle.ghost;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                style == ModernButtonStyle.primary ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isFullWidth ? double.infinity : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: _getIconSize()),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isFullWidth ? double.infinity : 0,
        minHeight: _getMinHeight(),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  double _getMinHeight() {
    switch (size) {
      case ModernButtonSize.small:
        return 36;
      case ModernButtonSize.medium:
        return 44;
      case ModernButtonSize.large:
        return 52;
    }
  }

  ButtonStyle _getButtonStyle() {
    switch (style) {
      case ModernButtonStyle.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        );
      case ModernButtonStyle.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        );
      case ModernButtonStyle.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        );
      case ModernButtonStyle.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ModernButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ModernButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ModernButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = switch (size) {
      ModernButtonSize.small => const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ModernButtonSize.medium => const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ModernButtonSize.large => const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    };

    final color = switch (style) {
      ModernButtonStyle.primary || ModernButtonStyle.secondary => Colors.white,
      ModernButtonStyle.outline || ModernButtonStyle.ghost => AppTheme.primaryColor,
    };

    return baseStyle.copyWith(color: color);
  }

  double _getIconSize() {
    switch (size) {
      case ModernButtonSize.small:
        return 16;
      case ModernButtonSize.medium:
        return 18;
      case ModernButtonSize.large:
        return 20;
    }
  }
}

enum ModernButtonStyle {
  primary,
  secondary,
  outline,
  ghost,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}