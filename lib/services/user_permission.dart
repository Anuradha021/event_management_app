// lib/services/user_permission_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPermissionService {
  static Future<Map<String, bool>> checkPermissions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = doc.data();
        if (data != null) {
          final isSystemAdmin = data['isSystemAdmin'] == true;
          final isRegularAdmin = data['role'] == 'admin';
          return {
            'isSystemAdmin': isSystemAdmin,
            'isRegularAdmin': isRegularAdmin,
          };
        }
      } catch (e) {
        print('Error checking user permissions: $e');
      }
    }
    return {
      'isSystemAdmin': false,
      'isRegularAdmin': false,
    };
  }
}
