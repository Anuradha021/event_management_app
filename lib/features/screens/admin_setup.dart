import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetupScreen extends StatefulWidget {
  @override
  _AdminSetupScreenState createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin21@event.com');
  final _passwordController = TextEditingController(text: 'Admin@1234');
  bool _isCreating = false;

  Future<void> _createAdmin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isCreating = true);
      try {
        // Create auth user
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Set custom claim
        await FirebaseAuth.instance.currentUser!
            .getIdTokenResult(true); // Refresh token

        // Create user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'name': 'System Admin',
        });

        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating admin: ${e.toString()}')),
        );
      } finally {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Admin Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isCreating
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createAdmin,
                      child: Text('Create Admin Account'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}