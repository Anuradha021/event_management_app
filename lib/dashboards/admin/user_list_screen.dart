import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({Key? key}) : super(key: key);

  Future<void> promoteToAdmin(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'role': 'admin'});
  }
  Future<void> demoteFromAdmin(String userId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'role': 'user'});
}


  @override
  Widget build(BuildContext context) {
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
              final isAdmin = userData['role'] == 'admin';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(isAdmin ? Icons.security : Icons.person)),
                  title: Text(userData['name'] ?? 'No Name'),
                  subtitle: Text(userData['email'] ?? 'No Email'),
                  trailing: isAdmin
    ? ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () => demoteFromAdmin(user.id),
        child: const Text('Remove Admin', style: TextStyle(color: Colors.white)),
      )
    : ElevatedButton(
        onPressed: () => promoteToAdmin(user.id),
        child: const Text('Make Admin'),
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
