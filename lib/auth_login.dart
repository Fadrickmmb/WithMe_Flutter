import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin_home_page.dart';
import 'auth_forgotPassword.dart';
import 'mod_home_page.dart';
import 'user_home_page.dart';

class AuthLogin extends StatefulWidget {
  @override
  _AuthLoginState createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userDatabase = FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _adminDatabase = FirebaseDatabase.instance.ref().child('admin');

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  void _checkLoggedInUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      checkUserRole(user.email!);
    }
  }

  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email and password are required'),
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        checkUserRole(user.email!);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.message}'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  void checkUserRole(String email) async {
    try {
      final adminSnapshot = await _adminDatabase.orderByChild('email').equalTo(email).get();
      if (adminSnapshot.exists) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHomePage()));
      } else {
        final modDatabase = FirebaseDatabase.instance.ref().child('mod');
        final modSnapshot = await modDatabase.orderByChild('email').equalTo(email).get();
        if (modSnapshot.exists) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ModHomePage()));
        } else {
          final userSnapshot = await _userDatabase.orderByChild('email').equalTo(email).get();
          if (userSnapshot.exists) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHomePage()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('No account found with this email'),
            ));
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error checking user role: $e'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/withme_logo.png',
              height: 92,
            ),
            SizedBox(height: 40),
            Text('Email', style: TextStyle(fontSize: 14)),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 20),
            Text('Password', style: TextStyle(fontSize: 14)),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/forgot_password' );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            SizedBox(height: 40),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: loginUser,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
              },
              child: Text(
                'Don\'t Have an Account? \n Register Here',
                textAlign: TextAlign.center,
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
