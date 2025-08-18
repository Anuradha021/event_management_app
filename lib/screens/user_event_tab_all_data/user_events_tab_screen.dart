import 'package:event_management_app1/screens/user_event_tab_all_data/widgets/assigned_events_section.dart';
import 'package:event_management_app1/screens/user_event_tab_all_data/widgets/create_event_request_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';


class UserEventsTabScreen extends StatefulWidget {
  const UserEventsTabScreen({super.key});

  @override
  State<UserEventsTabScreen> createState() => _UserEventsTabScreenState();
}

class _UserEventsTabScreenState extends State<UserEventsTabScreen> {
  bool _isOrganizer = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _isOrganizer = userData['isOrganizer'] == true;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isOrganizer = false;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isOrganizer = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isOrganizer = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Create Event Request Card
                  const CreateEventRequestCard(),

                  /// Assigned Events Section
                  if (_isOrganizer) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'My Assigned Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AssignedEventsSection(),
                  ],
                ],
              ),
            ),
    );
  }
}
