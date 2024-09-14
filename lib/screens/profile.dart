import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          // Populate the fields with existing user data
          setState(() {
            _nameController.text = userData['username'] ?? '';  // Update with 'username'
            _rollNoController.text = userData['rollNumber'] ?? '';  // Update with 'rollNumber'
            _profileImageUrl = userData['profile_image_url'];  // Update with 'profile_image_url'
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
Future<void> _saveProfile() async {
  try {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception("No user is logged in.");
    }

    String? imageUrl;
    if (_imageFile != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}');
      final uploadTask = storageRef.putFile(_imageFile!);

      // Monitor the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred.toDouble() / snapshot.totalBytes.toDouble();
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      try {
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
        print('Image URL: $imageUrl');
      } catch (e) {
        throw Exception("Failed to get download URL: $e");
      }
    }

    // Update Firestore with the profile image URL
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'profile_image_url': imageUrl ?? _profileImageUrl,  // If no new image is selected, keep the old URL
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }

    setState(() {
      _profileImageUrl = imageUrl ?? _profileImageUrl;  // Update the displayed profile image
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.08,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!) as ImageProvider
                              : null,
                      child: _imageFile == null && _profileImageUrl == null
                          ? const Icon(Icons.person, size: 80, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,  // Make the field uneditable
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _rollNoController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,  // Make the field uneditable
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: _saveProfile,
                child: const Text('Save Profile', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
