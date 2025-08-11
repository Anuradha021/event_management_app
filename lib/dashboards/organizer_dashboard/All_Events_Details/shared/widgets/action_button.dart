import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isFullWidth;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.deepPurple,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return isFullWidth 
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}


class UpdateButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const UpdateButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: Icons.edit,
      label: 'Update',
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}


class DeleteButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const DeleteButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: Icons.delete,
      label: 'Delete',
      onPressed: onPressed,
      backgroundColor: Colors.red,
      isLoading: isLoading,
    );
  }
}
