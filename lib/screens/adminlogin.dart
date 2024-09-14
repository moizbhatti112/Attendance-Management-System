import 'package:attendance/screens/adminpanel.dart';
import 'package:attendance/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String adminUsername = 'moiz';
  String adminPassword = 'admin';

  // void storeAdminCredentials() async {
  //   await firestore.collection('admin').doc('n2TZwumkEHdcYLUrI1qt').set({
  //     'username': 'moiz',
  //     'password': 'admin',
  //   });
  // }

  // Function to validate the admin login
  void _loginAdmin() async {
    String enteredUsername = _usernameController.text;
    String enteredPassword = _passwordController.text;

    try {
      // Fetch stored admin credentials from Firestore
      DocumentSnapshot adminData =
          await firestore.collection('admin').doc('n2TZwumkEHdcYLUrI1qt').get();

      if (adminData.exists) {
        String storedUsername = adminData['username'];
        String storedPassword = adminData['password'];

        if (enteredUsername == storedUsername &&
            enteredPassword == storedPassword) {
          // Login successful, navigate to the admin panel
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Successful! Welcome, Admin!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          // Navigate to the Admin Dashboard
          if (mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminDashboard()));
            _usernameController.clear();
            _passwordController.clear();
          }
        } else {
          // Show an error message if login fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Username or Password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // If the document doesn't exist, show an error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin credentials not found.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors that occur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              LottieBuilder.network(
                'https://lottie.host/9741be62-4123-4d43-a9d5-a47051ff772a/5fwf857NY9.json',
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: 'Admin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true, // To hide the password input
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Container(
                width: MediaQuery.of(context).size.height * 0.2,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.deepPurple,
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: _loginAdmin, // Call the login function here
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login as user? ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
