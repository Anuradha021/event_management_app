import 'package:flutter/material.dart';
import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/core/widgets/modern_card.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/orgnizer_dashboard_all_data/event_request_form.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/orgnizer_dashboard_all_data/assigned_event_list_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: AppTheme.headingSmall),
        const SizedBox(height: AppTheme.spacingM),

        // Create Event Request
        ModernCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ContactForm(isFromDashboard: true),
              ),
            );
          },
          child: _buildActionItem(
            icon: Icons.add_circle_outline,
            iconColor: AppTheme.secondaryColor,
            bgColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
            title: "Create New Event Request",
            subtitle: "Submit a new event proposal for approval",
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        // View Assigned Events
        ModernCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AssignedEventListScreen(),
              ),
            );
          },
          child: _buildActionItem(
            icon: Icons.event_note_outlined,
            iconColor: AppTheme.primaryColor,
            bgColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            title: "View My Assigned Events",
            subtitle: "Manage and organize your approved events",
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppTheme.radiusM)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.labelLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTheme.bodyMedium),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: AppTheme.textTertiary, size: 16),
      ],
    );
  }
}
