import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> signUp(String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Convert to UserModel
      return UserModel(
        uid: result.user!.uid,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error in sign-up: $e');
      return null;
    }
  }

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

  Future<void> logout() async {
    await _auth.signOut();
  }
}
