import 'package:flutter/material.dart';
import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/core/widgets/modern_card.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      backgroundColor: Colors.white,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back!", style: AppTheme.headingMedium),
                const SizedBox(height: 4),
                Text("Manage your events", style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
