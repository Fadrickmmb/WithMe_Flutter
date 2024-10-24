import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminCreateUserScreen extends StatefulWidget {
  @override
  _AdminCreateUserScreenState createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _adminDatabase = FirebaseDatabase.instance.reference().child('admin');
  final _modDatabase = FirebaseDatabase.instance.reference().child('mod');

  String _selectedRole = '';

  void _createUser() async {
    final userNameInput = _usernameController.text.trim();
    final emailInput = _emailController.text.trim();
    final passwordInput = _passwordController.text.trim();

    if (userNameInput.isEmpty) {
      _showError("Username is required");
      return;
    }

    if (emailInput.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailInput)) {
      _showError("Valid email is required");
      return;
    }

    if (passwordInput.isEmpty || passwordInput.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    if (_selectedRole.isEmpty) {
      _showError("Please choose Mod or Admin");
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailInput, password: passwordInput);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await firebaseUser.updateProfile(displayName: userNameInput);

        final userId = firebaseUser.uid;
        final newUser = {
          'username': userNameInput,
          'email': emailInput,
          'uid': userId,
        };

        if (_selectedRole == 'mod') {
          await _modDatabase.child(userId).set(newUser);
        } else if (_selectedRole == 'admin') {
          await _adminDatabase.child(userId).set(newUser);
        }

        _showSuccess("User created successfully!");
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError("User creation failed: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Text("Select Role:"),
            RadioListTile(
              title: Text('Moderator'),
              value: 'mod',
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            RadioListTile(
              title: Text('Administrator'),
              value: 'admin',
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _createUser,
                  child: Text('Create'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Home Screen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
