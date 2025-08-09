import 'package:flutter/material.dart';

/// Single Responsibility: Display panel header with title and create button
class PanelHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onCreatePressed;
  final String? createTooltip;
  final bool canCreate;

  const PanelHeader({
    super.key,
    required this.title,
    this.onCreatePressed,
    this.createTooltip,
    this.canCreate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: canCreate ? onCreatePressed : null,
          tooltip: createTooltip ?? 'Create',
        ),
      ],
    );
  }
}
