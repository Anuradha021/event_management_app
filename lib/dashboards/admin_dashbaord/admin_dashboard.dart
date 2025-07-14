import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/filter_chips.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/admi_dashboard_widgets/appbar_actions.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/admi_dashboard_widgets/event_request_list.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/admi_dashboard_widgets/search_box.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/admin_dashboard_services/user_permission.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedFilter = 'pending';
  String searchQuery = '';
  bool _isSystemAdmin = false;
  bool _isRegularAdmin = false;
  bool _isLoading = true;

 @override
void initState() {
  super.initState();
  _loadUserPermissions();
}
void _logout() async {
  await FirebaseAuth.instance.signOut();
  if (!mounted) return;
  Navigator.pushReplacementNamed(context, '/login'); 
}

Future<void> _loadUserPermissions() async {
  final result = await UserPermissionService.checkPermissions();

  setState(() {
    _isSystemAdmin = result['isSystemAdmin'] ?? false;
    _isRegularAdmin = result['isRegularAdmin'] ?? false;
    _isLoading = false;
  });
}
  Stream<QuerySnapshot> getEventRequestsStream() {
    try {
      final collection = FirebaseFirestore.instance.collection('event_requests');
      if (selectedFilter == 'all') {
        return collection.orderBy('createdAt', descending: true).snapshots();
      } else {
        return collection
            .where('status', isEqualTo: selectedFilter)
            .orderBy('createdAt', descending: true)
            .snapshots();
      }
    } catch (e) {
      return const Stream<QuerySnapshot>.empty();
    }
  }

  void _updateFilter(String filterValue) {
    setState(() => selectedFilter = filterValue);
  }

  void _updateSearchQuery(String query) {
    setState(() => searchQuery = query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isSystemAdmin && !_isRegularAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            ' Access Denied. ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSystemAdmin ? 'System Admin Dashboard' : 'Admin Dashboard'),
       actions: [
  Padding(
    padding: const EdgeInsets.only(right: 12),
    child: AdminAppBarActions(isSystemAdmin: _isSystemAdmin, onLogout: _logout,),
    
  ),
],

      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            SearchBox(onChanged: _updateSearchQuery),

            const SizedBox(height: 15),
            FilterChips(
              selectedFilter: selectedFilter,
              onFilterSelected: _updateFilter,
            ),
            const SizedBox(height: 15),
            Expanded(
  child: EventRequestList(
    selectedFilter: selectedFilter,
    searchQuery: searchQuery,
  ),
),

          ],
        ),
      ),
    );
  }
}