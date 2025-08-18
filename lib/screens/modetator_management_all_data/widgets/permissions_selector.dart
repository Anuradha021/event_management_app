import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/orgnizer_dashboard_all_data/moderator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';


class PermissionsSelector extends StatefulWidget {
  final List<String> selectedPermissions;

  const PermissionsSelector({super.key, required this.selectedPermissions});

  @override
  State<PermissionsSelector> createState() => _PermissionsSelectorState();
}

class _PermissionsSelectorState extends State<PermissionsSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: ModeratorPermissions.all.map((permission) {
        return CheckboxListTile(
          title: Text(ModeratorPermissions.getDisplayName(permission)),
          subtitle: Text(
            ModeratorPermissions.getDescription(permission),
            style: const TextStyle(fontSize: 12),
          ),
          value: widget.selectedPermissions.contains(permission),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                widget.selectedPermissions.add(permission);
              } else {
                widget.selectedPermissions.remove(permission);
              }
            });
          },
          activeColor: AppTheme.primaryColor,
          dense: true,
        );
      }).toList(),
    );
  }
}
