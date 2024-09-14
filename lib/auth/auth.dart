import 'package:attendance/screens/homepage.dart';
import 'package:attendance/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth status
        
        // If the user is authenticated, show Homepage
        if (snapshot.hasData) {
          return const Homepage();
        }

        // If no user is signed in, show LoginScreen
        return const LoginScreen();
      },
    );
  }
}
