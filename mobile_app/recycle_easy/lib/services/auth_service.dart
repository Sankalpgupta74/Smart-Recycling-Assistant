import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';



class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  // Stream of user state
  Stream<auth.User?> get user => _firebaseAuth.authStateChanges();

  // Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(name);
      return null; // Success
    } on auth.FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error (${e.code}): ${e.message}");
      return e.message;
    } catch (e) {
      debugPrint("Unexpected Auth Error: $e");
      return "An unexpected error occurred.";
    }

  }

  // Login
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
