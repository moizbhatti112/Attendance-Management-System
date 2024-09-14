import 'package:attendance/helper/errormsg.dart';
import 'package:attendance/screens/adminlogin.dart';
import 'package:attendance/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController usernamecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController cnfrmpasswordcontroller = TextEditingController();
   final TextEditingController rollcontroller = TextEditingController();

  void registeruser() async {
  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  // Check if passwords match
  if (passwordcontroller.text != cnfrmpasswordcontroller.text) {
    Navigator.pop(context);
    displayerror('Password Does Not Match', context);
  } else {
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailcontroller.text.trim(), 
              password: passwordcontroller.text.trim()
          );

      // Get the user's UID
      String uid = userCredential.user!.uid;

      // Add user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': usernamecontroller.text.trim(),
        'rollNumber': rollcontroller.text.trim(),
        'email': emailcontroller.text.trim(),
      });

      // Clear the text fields after successful registration
      usernamecontroller.clear();
      rollcontroller.clear();
      emailcontroller.clear();
      passwordcontroller.clear();
      cnfrmpasswordcontroller.clear();

      if (mounted) Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign Up Successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        displayerror(e.code, context);
      }
    }
  }
}

  void showEmptyFieldsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Please fill all the fields'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void handleSignUp() {
  // Validate fields before proceeding
  if (usernamecontroller.text.isEmpty ||
      rollcontroller.text.isEmpty ||
      emailcontroller.text.isEmpty ||
      passwordcontroller.text.isEmpty ||
      cnfrmpasswordcontroller.text.isEmpty) {
    showEmptyFieldsDialog();
  } else {
    registeruser();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.1,
              // ),
              LottieBuilder.network(
                'https://lottie.host/9741be62-4123-4d43-a9d5-a47051ff772a/5fwf857NY9.json',
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: usernamecontroller,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      hintText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                ),
              ),
                SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: rollcontroller,
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.numbers),
                      hintText: 'Roll Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: passwordcontroller,
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: cnfrmpasswordcontroller,
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
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
                    color: Colors.deepPurple),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      handleSignUp();
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
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
                  const Text('Already Have An Account? ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  InkWell(
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                    },
                  ),
                ],
              ),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Login as Admin? ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  InkWell(
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLogin(),
                          ));
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      );
    
  }
}
