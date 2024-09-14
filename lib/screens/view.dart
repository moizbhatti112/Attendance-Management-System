import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewAttendancePage extends StatelessWidget {
  const ViewAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Your Attendance Records',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          // Fetch user data (roll number and username)
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String rollNumber = userData['rollNumber'] ?? 'Unknown Roll Number';
          String username = userData['username'] ?? 'Unknown Username';

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('attendance')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, attendanceSnapshot) {
              if (attendanceSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!attendanceSnapshot.hasData ||
                  attendanceSnapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No attendance records found.'));
              }

              List<DocumentSnapshot> attendanceRecords =
                  attendanceSnapshot.data!.docs;

              return ListView.builder(
                itemCount: attendanceRecords.length,
                itemBuilder: (context, index) {
                  var record =
                      attendanceRecords[index].data() as Map<String, dynamic>;
                  Timestamp timestamp = record['timestamp'];
                  DateTime dateTime = timestamp.toDate();

                  return Card(
                    elevation: 4, // Adds shadow to make it stand out
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Roll No: $rollNumber",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8), // Adds vertical spacing
                          Text(
                            "Username: $username",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.event_note,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                "Marked: ${record['type']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                "Date: ${dateTime.toLocal().toString().substring(0, 19)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
