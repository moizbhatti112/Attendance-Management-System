import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch all students' data from Firestore
  Stream<QuerySnapshot> getStudentsStream() {
    return firestore.collection('users').snapshots();
  }

  // Mark a student as present or absent only if the status is different
  void markAttendance(String studentId, bool isPresent, bool currentStatus) async {
    if (isPresent != currentStatus) {
      await firestore.collection('users').doc(studentId).update({
        'attendance': isPresent,
        'lastMarked': FieldValue.serverTimestamp(), // Update the lastMarked time
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        title: const Text('Admin Panel ',style: TextStyle(color: Colors.white),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getStudentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              var data = student.data() as Map<String, dynamic>?;

              if (data == null) {
                return const ListTile(
                  title: Text('Invalid student data'),
                );
              }

              (data['lastMarked'] as Timestamp?)?.toDate();

              // Handle null fields by providing default values
              String username = data['username'] ?? 'Unknown';
              String rollNumber = data['rollNumber'] ?? 'No roll number';
              String profileImageUrl = data['profile_image_url'] ?? 'https://via.placeholder.com/150'; // Placeholder image URL

              bool attendance = data.containsKey('attendance') 
                  ? data['attendance'] 
                  : false; // Default to 'Absent' if not set

              String attendanceStatus = attendance ? 'Present' : 'Absent';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                  radius: 30,
                ),
                title: Text(username),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('Email: $email'),
                    Text('Roll Number: $rollNumber'),
                    Text('Status: $attendanceStatus'),
                    // if (lastMarked != null) Text('Last Marked: $lastMarked'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => markAttendance(student.id, true, attendance),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: attendance ? Colors.green : Colors.grey,
                      ),
                      child: const Text('Present'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => markAttendance(student.id, false, attendance),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !attendance ? Colors.red : Colors.grey,
                      ),
                      child: const Text('Absent'),
                    ),
                  ],
                ),
                
              );
            },
          );
        },
      ),
    );
  }
}
