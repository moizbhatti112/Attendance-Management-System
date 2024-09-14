import 'package:attendance/components/buttons.dart';
import 'package:attendance/screens/mydrawer.dart';
import 'package:attendance/screens/view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isButtonDisabled = false;
 bool isWeekend = DateTime.now().weekday == DateTime.sunday;


  @override
  void initState() {
    super.initState();
    _checkIfAttendanceIsMarked();  // Check on load
  }

  Future<void> _checkIfAttendanceIsMarked() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userId = user.uid;
    final now = DateTime.now();

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('lastMarked')) {
        Timestamp lastMarked = userData['lastMarked'];
        // Check if less than 24 hours have passed since last mark
        if (now.difference(lastMarked.toDate()).inHours < 24) {
          setState(() {
            isButtonDisabled = true;  // Disable the button if marked within 24 hours
          });
        } else {
          setState(() {
            isButtonDisabled = false;  // Enable the button if 24 hours have passed
          });
        }
      } else {
        // If 'lastMarked' does not exist, this is likely a new user
        setState(() {
          isButtonDisabled = false;  // Enable the buttons for new users
        });
      }
    }
  }
}


  // Method to mark attendance
  Future<void> markAttendance(String type) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final now = DateTime.now();

      if (isWeekend) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot mark attendance on Saturday or Sunday'),
        ));
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('lastMarked')) {
          Timestamp lastMarked = userData['lastMarked'];
          if (now.difference(lastMarked.toDate()).inHours < 24) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('You cannot mark attendance until 24 hours complete'),
            ));
            return;
          }
        }
      }

      // Save attendance record in the attendance sub-collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .add({
        'type': type,
        'timestamp': Timestamp.fromDate(now),
      });

      // Update last marked time and current attendance status (present or absent)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'lastMarked': Timestamp.fromDate(now),
        'attendanceStatus': type,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Attendance marked successfully'),
      ));

      setState(() {
        isButtonDisabled = true; // Disable the button after marking
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: MediaQuery.of(context).size.height * 0.08,
          centerTitle: true,
          title: const Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        drawer: const Mydrawer(),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Mybutton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.fingerprint_outlined, size: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonDisabled || isWeekend
                            ? Colors.grey
                            : Colors.green,
                      ),
                      onPressed: isButtonDisabled || isWeekend
                          ? null
                          : () {
                              markAttendance('present');
                            },
                      child: const Text(
                        'Mark Present',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              Mybutton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.event_busy, size: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonDisabled || isWeekend
                            ? Colors.grey
                            : Colors.red,
                      ),
                      onPressed: isButtonDisabled || isWeekend
                          ? null
                          : () {
                              markAttendance('leave');
                            },
                      child: const Text(
                        'Mark Leave',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              Mybutton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.visibility, size: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewAttendancePage(),
                          ),
                        );
                      },
                      child: const Text(
                        'View Attendance',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
