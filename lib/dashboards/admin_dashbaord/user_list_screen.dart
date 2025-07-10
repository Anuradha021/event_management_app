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
              final isSystemAdmin = userData['isSystemAdmin'] == true;
              final isCurrentUser = currentUser?.uid == userId;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(isAdmin ? Icons.security : Icons.person),
                  ),
                  title: Text(userName),
                  subtitle: Text(userEmail),
                 trailing: isAdmin
    ? ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () => _demoteFromAdmin(context, userId),
        child: const Text("Remove Admin", style: TextStyle(color: Colors.white)),
      )
    : ElevatedButton(
        onPressed: () => _promoteToAdmin(context, userId),
        child: const Text("Make Admin"),
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
