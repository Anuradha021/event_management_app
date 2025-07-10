import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/features/screens/contact_form.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/organizer_dashboard.dart';

class EntryPointScreen extends StatelessWidget {
  const EntryPointScreen({super.key});

  Future<bool> _isOrganizer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      return userData['isOrganizer'] == true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOrganizer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data == true) {
          return const OrganizerDashboardScreen();
        } else {
          return const ContactForm(isFromDashboard: false);
        }
      },
    );
  }
}
