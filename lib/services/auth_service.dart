import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Error signing in: ${e.toString()}");
      throw e;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Error registering: ${e.toString()}");
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: ${e.toString()}");
      throw e;
    }
  }

  // Stream of auth changes
  Stream<User?> get user => _auth.authStateChanges();

  // Current user helper
  User? get currentUser => _auth.currentUser;

  // Check if current user is admin
  bool get isAdmin {
    final user = _auth.currentUser;
    if (user == null) return false;
    return adminUIDs.contains(user.uid);
  }
}
