import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/orgnizer_dashboard_all_data/orgnizer_dashboard_widget/quick_actions_section.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/orgnizer_dashboard_all_data/orgnizer_dashboard_widget/welcome_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndShowApprovalPopup();
  }

  Future<void> _checkAndShowApprovalPopup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();
    final data = docSnapshot.data();

    if (data != null && data['isOrganizer'] == true && (data['popupShown'] == false || data['popupShown'] == null)) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Approval Received"),
          content: const Text("Congratulations! You are now an approved organizer."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await docRef.update({'popupShown': true});
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Organizer Dashboard"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            WelcomeHeader(),
            SizedBox(height: AppTheme.spacingXL),
            QuickActionsSection(),
          ],
        ),
      ),
    );
  }
}
