import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/firestore_logger.dart';

/// User roles supported by the app.
class UserRole {
  UserRole._();

  static const doctor = 'doctor';
  static const client = 'client';
}

class AuthRepository {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Register a new account.
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.register(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Send a password reset email.
  Future<void> forgotPassword({required String email}) async {
    try {
      await _authService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Resolve the role of a user.
  ///
  /// Reads the lightweight `users` doc first, then falls back to checking
  /// the `doctors` and `clients` collections so existing accounts still work.
  ///
  /// Requires a signed-in user whose uid matches the requested document.
  Future<String> getUserRole(String uid) async {
    try {
      final currentUid = _authService.currentUser?.uid ?? '';
      if (uid.isEmpty || currentUid.isEmpty) {
        FirestoreLogger.log(
          collection: 'users',
          operation: 'getRole',
          details: 'uid=$uid currentUid=$currentUid | unauthenticated',
        );
        return UserRole.client;
      }

      FirestoreLogger.log(
        collection: 'users',
        operation: 'read',
        details: 'doc=$uid',
      );
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role'];
        if (role == UserRole.doctor || role == UserRole.client) {
          FirestoreLogger.log(
            collection: 'users',
            operation: 'read',
            details: 'doc=$uid role=$role',
          );
          return role;
        }
      }

      FirestoreLogger.log(
        collection: 'doctors',
        operation: 'read',
        details: 'doc=$uid',
      );
      final doctorDoc = await _firestore.collection('doctors').doc(uid).get();
      if (doctorDoc.exists) {
        await _ensureUserDoc(uid, UserRole.doctor);
        return UserRole.doctor;
      }

      await _ensureUserDoc(uid, UserRole.client);
      return UserRole.client;
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'users',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'users',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Re-create the lightweight `users` doc when it is missing so role
  /// resolution keeps working for accounts created before signup persisted
  /// the profile. Best-effort: never fails the caller.
  Future<void> _ensureUserDoc(String uid, String role) async {
    try {
      FirestoreLogger.log(
        collection: 'users',
        operation: 'read',
        details: 'doc=$uid (ensure exists)',
      );
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) return;

      final authUser = _authService.currentUser;
      FirestoreLogger.log(
        collection: 'users',
        operation: 'set',
        details: 'doc=$uid role=$role (self-heal)',
      );
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': authUser?.displayName ?? '',
        'email': authUser?.email ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'users',
        operation: 'set',
        error: e,
      );
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'users',
        operation: 'set',
        error: e,
      );
    }
  }

  /// Save the profile for a registered user based on their role.
  Future<void> saveProfile({
    required String uid,
    required String role,
    required String name,
    required String email,
    String phone = '',
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'users',
        operation: 'set',
        details: 'doc=$uid role=$role',
      );
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final profile = <String, dynamic>{
        'name': name,
        'email': email,
        'uid': uid,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (phone.isNotEmpty) profile['phone'] = phone;

      final collection = role == UserRole.doctor ? 'doctors' : 'clients';
      FirestoreLogger.log(
        collection: collection,
        operation: 'set',
        details: 'doc=$uid role=$role',
      );
      await _firestore
          .collection(collection)
          .doc(uid)
          .set(profile, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'users',
        operation: 'set',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'users',
        operation: 'set',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Update the stored FCM token for the current user.
  Future<void> saveFcmToken({
    required String uid,
    required String role,
    required String token,
  }) async {
    try {
      if (token.isEmpty) return;
      final collection = role == UserRole.doctor ? 'doctors' : 'clients';
      FirestoreLogger.log(
        collection: collection,
        operation: 'update',
        details: 'doc=$uid (fcmToken)',
      );
      await _firestore.collection(collection).doc(uid).update({
        'fcmToken': token,
      });
    } on FirebaseException catch (e) {
      // Token sync should never block the app.
      FirestoreLogger.logError(
        collection: 'fcmToken',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'fcmToken',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Sign out the current user.
  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw FirebaseErrorMapper.map(e);
    }
  }
}
