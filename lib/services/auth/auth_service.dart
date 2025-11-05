import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //instance of AuthService
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user email
  User? get currentUser => _auth.currentUser;

  // sign in method
  Future<UserCredential> signIn(String email, String password) async {
    try {
      // sign in user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  // sign up method
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      // create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user info in a separate Firestore collection
      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        "email": email,
        "uid": userCredential.user!.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    }
  }

  // sign out method
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // errors
}
