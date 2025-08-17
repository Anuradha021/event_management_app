 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool _isLoading = true;
  bool _isSystemAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkSystemAdminStatus();
  }

  Future<void> _checkSystemAdminStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final data = userDoc.data();
    if (data != null && data['isSystemAdmin'] == true) {
      setState(() {
        _isSystemAdmin = true;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promoteToAdmin(BuildContext context, String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': 'admin',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(" User promoted to Admin")),
    );
  }

  Future<void> _demoteFromAdmin(BuildContext context, String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': 'user',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin demoted to User")),
    );
  }

  Future<void> _promoteToOrganizer(BuildContext context, String userId, String userName) async {
    // Show confirmation popup
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assign as Organizer'),
          content: Text('Are you sure you want to assign $userName as an Organizer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isOrganizer': true,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$userName has been assigned as Organizer')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _demoteFromOrganizer(BuildContext context, String userId, String userName) async {
    // Show confirmation popup
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Organizer Role'),
          content: Text('Are you sure you want to remove $userName from Organizer role?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isOrganizer': false,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$userName has been removed from Organizer role')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isSystemAdmin) {
      return const Scaffold(
        body: Center(child: Text("Access Denied. Only System Admin can manage users.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;
              final userId = user.id;
              final userName = userData['name'] ?? 'Unnamed';
              final userEmail = userData['email'] ?? 'No Email';
              final role = userData['role'] ?? 'user';
              final isAdmin = role == 'admin';
              final isOrganizer = userData['isOrganizer'] == true;
              final isSystemAdmin = userData['isSystemAdmin'] == true;
              final isCurrentUser = currentUser?.uid == userId;

              // Don't allow modifying system admin or current user
              if (isSystemAdmin || isCurrentUser) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                    ),
                    title: Text(userName),
                    subtitle: Text('$userEmail\nSystem Admin'),
                    trailing: const Chip(
                      label: Text('System Admin'),
                      backgroundColor: Colors.purple,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin
                        ? Colors.red
                        : isOrganizer
                            ? Colors.green
                            : Colors.blue,
                    child: Icon(
                      isAdmin
                          ? Icons.security
                          : isOrganizer
                              ? Icons.event
                              : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(userName),
                  subtitle: Text('$userEmail\n${isAdmin ? 'Admin' : isOrganizer ? 'Organizer' : 'User'}'),
                  trailing: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Admin Management
                        if (isAdmin)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(80, 32),
                            ),
                            onPressed: () => _demoteFromAdmin(context, userId),
                            child: const Text("Remove Admin",
                                style: TextStyle(color: Colors.white, fontSize: 10)),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(80, 32),
                            ),
                            onPressed: () => _promoteToAdmin(context, userId),
                            child: const Text("Make Admin", style: TextStyle(fontSize: 10)),
                          ),

                        const SizedBox(width: 8),

                        // Organizer Management
                        if (isOrganizer)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: const Size(80, 32),
                            ),
                            onPressed: () => _demoteFromOrganizer(context, userId, userName),
                            child: const Text("Remove Org",
                                style: TextStyle(color: Colors.white, fontSize: 10)),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(80, 32),
                            ),
                            onPressed: () => _promoteToOrganizer(context, userId, userName),
                            child: const Text("Make Org",
                                style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
