import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/User_dashboard/user_screens/UserBottomNav.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/admin_dashboard.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/organizer_dashboard.dart';
import 'package:event_management_app1/features/screens/contact_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EntryPointScreen extends StatelessWidget {
  const EntryPointScreen({super.key});

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'guest';

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      if (userData['isAdmin'] == true) return 'admin';
      if (userData['isOrganizer'] == true) return 'organizer';
      return 'user';
    }

    return 'guest';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        switch (snapshot.data) {
          case 'admin':
            return const AdminDashboard();
          case 'organizer':
            return const OrganizerDashboardScreen();
          case 'user':
            return const UserBottomNav(); // normal user
          default:
            return const ContactForm(isFromDashboard: false);
        }
      },
    );
  }
}
