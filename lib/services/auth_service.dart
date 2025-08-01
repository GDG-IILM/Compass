// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email,
      String password,
      String fullName,
      String branch,
      int semester,
      ) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(
        result.user!,
        fullName,
        branch,
        semester,
      );

      // Update display name
      await result.user!.updateDisplayName(fullName);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
      User user,
      String fullName,
      String branch,
      int semester,
      ) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'fullName': fullName,
        'name': fullName, // Also store as 'name' for compatibility
        'branch': branch,
        'semester': semester,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileImageUrl': null,
        'isActive': true,
        'isEmailVerified': false,
        'role': 'student',
      });
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? branch,
    int? semester,
    String? profileImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) {
        updateData['fullName'] = fullName;
        updateData['name'] = fullName; // Update both fields
        await user.updateDisplayName(fullName);
      }
      if (branch != null) updateData['branch'] = branch;
      if (semester != null) updateData['semester'] = semester;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Get user data stream
  Stream<DocumentSnapshot> getUserDataStream() {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  // Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticateUser(String password) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Re-authentication failed: ${e.toString()}');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }
}