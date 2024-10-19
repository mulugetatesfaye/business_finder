import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User not found.'));
            }

            // Fetch user data
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            final displayName = userData['displayName'] ?? 'No name available';
            final email = userData['email'] ?? 'No email available';
            final profilePicUrl = userData['profilePictureUrl'] ??
                'https://via.placeholder.com/150'; // Default placeholder
            final bio = userData['bio'] ?? 'No bio available.';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(profilePicUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(displayName,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black)),
                        const SizedBox(height: 4),
                        Text(
                          bio,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.black),
                          foregroundColor:
                              WidgetStatePropertyAll(Colors.white)),
                      onPressed: () {
                        // Handle edit profile action
                      },
                      child: const Text('Edit profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Email: $email',
                    style: const TextStyle(color: Colors.black)),
                // Add more fields as needed
              ],
            );
          },
        ),
      ),
    );
  }
}
