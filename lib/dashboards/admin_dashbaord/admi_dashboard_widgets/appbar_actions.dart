import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/create_event_screen.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/user_list_screen.dart';

class AdminAppBarActions extends StatelessWidget {
  final bool isSystemAdmin;
  final VoidCallback onLogout; 

  const AdminAppBarActions({
    super.key,
    required this.isSystemAdmin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 3,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateEventScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Event', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        if (isSystemAdmin)
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            tooltip: 'Manage Users',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserListScreen()),
              );
            },
          ),
        const SizedBox(width: 10),
        IconButton( 
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: onLogout,
        ),
      ],
    );
  }
}
