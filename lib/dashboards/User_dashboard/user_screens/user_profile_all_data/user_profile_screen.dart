import 'package:event_management_app1/dashboards/User_dashboard/user_screens/user_profile_all_data/widgets/logout_button.dart';
import 'package:event_management_app1/dashboards/User_dashboard/user_screens/user_profile_all_data/widgets/profile_header.dart';
import 'package:event_management_app1/dashboards/User_dashboard/user_screens/user_profile_all_data/widgets/profile_info_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';


class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          _userData = userDoc.data() ?? {
            'name': user.displayName ?? 'User',
            'email': user.email ?? '',
            'isOrganizer': false,
          };
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _userData = {
            'name': user.displayName ?? 'User',
            'email': user.email ?? '',
            'isOrganizer': false,
          };
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ProfileHeader(
                    name: _userData?['name'] ?? user?.displayName ?? 'User',
                    email: _userData?['email'] ?? user?.email ?? '',
                    isOrganizer: _userData?['isOrganizer'] == true,
                  ),
                  const SizedBox(height: 24),
                  ProfileInfoCard(
                    name: _userData?['name'] ?? user?.displayName ?? 'Not set',
                    email: _userData?['email'] ?? user?.email ?? 'Not set',
                    role: (_userData?['isOrganizer'] == true) ? 'Organizer' : 'User',
                    memberSince: _formatDate(user?.metadata.creationTime),
                  ),
                  const SizedBox(height: 24),
                  LogoutButton(onLogout: _logout),
                ],
              ),
            ),
    );
  }
}
