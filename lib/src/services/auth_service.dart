import 'dart:io';

import 'package:business_finder/src/services/abstracts/iauth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<IAuthService>((ref) {
  return FirebaseAuthService();
});

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<UserModel?> signUp(String email, String password, String role,
      {String? username, File? profilePic}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) return null;

      String? profilePicUrl;
      if (profilePic != null) {
        final storageRef = _storage.ref('users/${user.uid}/profile.jpg');
        final uploadTask = await storageRef.putFile(profilePic);
        profilePicUrl = await uploadTask.ref.getDownloadURL();
      }

      // Save user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'username': username,
        'role': role,
        'profilePictureUrl': profilePicUrl,
        'createdAt': DateTime.now(),
      });

      return UserModel(
        uid: user.uid,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error in sign-up: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        // Fetch role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        String role = userDoc['role'] ?? 'user';

        return UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          role: role,
          createdAt: DateTime.now(), // Adjust if needed
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error in login: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
